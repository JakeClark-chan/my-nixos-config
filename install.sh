#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# NixOS Automated Installer with Btrfs
# Supports both clean install and dual-boot alongside Windows
# ============================================================

# --- Config ---
REPO_URL="https://github.com/JakeClark-chan/my-nixos-config.git"
BRANCH="niri"
HOSTNAME="JakeClark-Sep21st"
USERNAME="jc"
INSTALL_DIR="/mnt/home/$USERNAME/nixos-config"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
header()  { echo -e "\n${BOLD}═══════════════════════════════════════${NC}"; echo -e "${BOLD}  $1${NC}"; echo -e "${BOLD}═══════════════════════════════════════${NC}\n"; }

confirm() {
    local prompt="$1"
    local response
    while true; do
        read -rp "$(echo -e "${YELLOW}$prompt [y/n]: ${NC}")" response
        case "$response" in
            [yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][oO]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

pause() {
    read -rp "$(echo -e "${CYAN}Press Enter to continue...${NC}")"
}

# ============================================================
# STEP 1: Check root
# ============================================================
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root. Run: sudo -i"
    exit 1
fi

header "NixOS Automated Installer (Btrfs)"
echo "This script will guide you through installing NixOS with Btrfs."
echo "Supports clean install and dual-boot alongside Windows."
echo ""

# ============================================================
# STEP 2: Network check
# ============================================================
header "Step 1: Network Connectivity"

check_internet() {
    ping -c 1 -W 3 google.com &>/dev/null || ping -c 1 -W 3 1.1.1.1 &>/dev/null
}

if check_internet; then
    success "Internet connection detected."
else
    warn "No internet connection detected."
    echo ""
    echo "  1) Connect via Wi-Fi (nmtui)"
    echo "  2) Try DHCP on Ethernet"
    echo "  3) Skip (I'll fix it myself)"
    echo ""
    read -rp "Choose [1/2/3]: " net_choice

    case "$net_choice" in
        1)
            systemctl start NetworkManager 2>/dev/null || true
            sleep 2
            nmtui
            ;;
        2)
            info "Starting DHCP client..."
            dhcpcd &>/dev/null || systemctl start dhcpcd 2>/dev/null || true
            sleep 5
            ;;
        3)
            warn "Skipping network setup."
            ;;
    esac

    if check_internet; then
        success "Internet connection established."
    else
        error "Still no internet. Some steps may fail."
        if ! confirm "Continue anyway?"; then
            exit 1
        fi
    fi
fi

# ============================================================
# STEP 3: Install dependencies
# ============================================================
header "Step 2: Installing Dependencies"
info "Installing git..."
nix-env -iA nixos.git 2>/dev/null || true
success "Dependencies ready."

# ============================================================
# STEP 4: Disk identification
# ============================================================
header "Step 3: Disk Identification"

echo "Available disks:"
echo ""
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "disk"
echo ""

# List disks into an array
mapfile -t disks < <(lsblk -d -n -o NAME,SIZE,TYPE | grep "disk" | awk '{print "/dev/"$1" ("$2")"}')

if [ ${#disks[@]} -eq 0 ]; then
    error "No disks found!"
    exit 1
elif [ ${#disks[@]} -eq 1 ]; then
    DISK="/dev/$(lsblk -d -n -o NAME | grep -E "^(sd|nvme|vd)" | head -1)"
    info "Only one disk found: $DISK"
else
    echo "Select a disk:"
    for i in "${!disks[@]}"; do
        echo "  $((i+1))) ${disks[$i]}"
    done
    echo ""
    read -rp "Choose [1-${#disks[@]}]: " disk_choice
    DISK="/dev/$(lsblk -d -n -o NAME | grep -E "^(sd|nvme|vd)" | sed -n "${disk_choice}p")"
fi

echo ""
info "Selected disk: $DISK"
echo ""
echo "Current partition layout:"
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DISK"
echo ""

# ============================================================
# STEP 5: Partitioning choice
# ============================================================
header "Step 4: Partitioning"

echo "  1) Clean install — wipe disk, create EFI + Btrfs (DESTROYS ALL DATA)"
echo "  2) Dual boot — use existing partitions / unallocated space"
echo "  3) Manual — open cfdisk to partition yourself"
echo ""
read -rp "Choose [1/2/3]: " part_choice

EFI_PART=""
BTRFS_PART=""

# Helper to get partition suffix
get_part() {
    local disk="$1"
    local num="$2"
    if [[ "$disk" == *"nvme"* ]] || [[ "$disk" == *"mmcblk"* ]]; then
        echo "${disk}p${num}"
    else
        echo "${disk}${num}"
    fi
}

case "$part_choice" in
    1)
        # --- Clean install ---
        warn "This will WIPE ALL DATA on $DISK!"
        if ! confirm "Are you absolutely sure?"; then
            error "Aborted."
            exit 1
        fi

        info "Wiping and partitioning $DISK..."
        wipefs -af "$DISK"
        parted "$DISK" -- mklabel gpt
        parted "$DISK" -- mkpart ESP fat32 1MiB 1024MiB
        parted "$DISK" -- set 1 esp on
        parted "$DISK" -- mkpart primary 1024MiB 100%

        EFI_PART=$(get_part "$DISK" 1)
        BTRFS_PART=$(get_part "$DISK" 2)

        info "Formatting EFI partition ($EFI_PART)..."
        mkfs.fat -F 32 -n BOOT "$EFI_PART"

        info "Formatting Btrfs partition ($BTRFS_PART)..."
        mkfs.btrfs -f -L nixos "$BTRFS_PART"

        success "Partitioning complete."
        ;;

    2)
        # --- Dual boot ---
        echo ""
        echo "Current partitions on $DISK:"
        echo ""
        lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL "$DISK"
        echo ""

        # Select EFI partition
        mapfile -t parts < <(lsblk -n -o NAME "$DISK" | tail -n +2 | sed 's/[├└│─ ]//g')

        echo "Select your EFI partition (FAT32, usually the first small one):"
        for i in "${!parts[@]}"; do
            local_part="/dev/${parts[$i]}"
            local_info=$(lsblk -n -o SIZE,FSTYPE,LABEL "$local_part" 2>/dev/null | head -1)
            echo "  $((i+1))) ${parts[$i]}  $local_info"
        done
        echo ""
        read -rp "EFI partition [1-${#parts[@]}]: " efi_choice
        EFI_PART="/dev/${parts[$((efi_choice-1))]}"
        info "EFI partition: $EFI_PART"

        # Select or create Btrfs partition
        echo ""
        echo "Select your Btrfs partition (or an empty partition to format):"
        for i in "${!parts[@]}"; do
            local_part="/dev/${parts[$i]}"
            local_info=$(lsblk -n -o SIZE,FSTYPE,LABEL "$local_part" 2>/dev/null | head -1)
            echo "  $((i+1))) ${parts[$i]}  $local_info"
        done
        echo "  0) Open cfdisk to create a new partition first"
        echo ""
        read -rp "Btrfs partition [0-${#parts[@]}]: " btrfs_choice

        if [ "$btrfs_choice" -eq 0 ]; then
            cfdisk "$DISK"
            # Re-read partitions
            partprobe "$DISK" 2>/dev/null || true
            sleep 2
            mapfile -t parts < <(lsblk -n -o NAME "$DISK" | tail -n +2 | sed 's/[├└│─ ]//g')
            echo ""
            echo "Updated partitions:"
            for i in "${!parts[@]}"; do
                local_part="/dev/${parts[$i]}"
                local_info=$(lsblk -n -o SIZE,FSTYPE,LABEL "$local_part" 2>/dev/null | head -1)
                echo "  $((i+1))) ${parts[$i]}  $local_info"
            done
            echo ""
            read -rp "Now select the Btrfs partition [1-${#parts[@]}]: " btrfs_choice
        fi

        BTRFS_PART="/dev/${parts[$((btrfs_choice-1))]}"
        info "Btrfs partition: $BTRFS_PART"

        # Check if we need to format it
        current_fs=$(lsblk -n -o FSTYPE "$BTRFS_PART" | head -1)
        if [ "$current_fs" != "btrfs" ]; then
            warn "Partition $BTRFS_PART is not btrfs (current: ${current_fs:-empty})."
            if confirm "Format $BTRFS_PART as Btrfs? (ALL DATA ON THIS PARTITION WILL BE LOST)"; then
                mkfs.btrfs -f -L nixos "$BTRFS_PART"
                success "Formatted as Btrfs."
            else
                error "Cannot continue without a Btrfs partition."
                exit 1
            fi
        fi

        success "Partitions selected."
        ;;

    3)
        # --- Manual ---
        cfdisk "$DISK"
        partprobe "$DISK" 2>/dev/null || true
        sleep 2

        mapfile -t parts < <(lsblk -n -o NAME "$DISK" | tail -n +2 | sed 's/[├└│─ ]//g')
        echo ""
        lsblk -o NAME,SIZE,FSTYPE,LABEL "$DISK"
        echo ""

        read -rp "Enter EFI partition (e.g. /dev/nvme0n1p1): " EFI_PART
        read -rp "Enter Btrfs partition (e.g. /dev/nvme0n1p2): " BTRFS_PART

        current_fs=$(lsblk -n -o FSTYPE "$BTRFS_PART" | head -1)
        if [ "$current_fs" != "btrfs" ]; then
            if confirm "Format $BTRFS_PART as Btrfs?"; then
                mkfs.btrfs -f -L nixos "$BTRFS_PART"
            fi
        fi
        ;;
esac

echo ""
success "EFI  partition: $EFI_PART"
success "Btrfs partition: $BTRFS_PART"
pause

# ============================================================
# STEP 6: Create Btrfs subvolumes
# ============================================================
header "Step 5: Creating Btrfs Subvolumes"

info "Mounting $BTRFS_PART temporarily..."
mount "$BTRFS_PART" /mnt

# Check if subvolumes already exist
existing_subvols=$(btrfs subvolume list /mnt 2>/dev/null | awk '{print $NF}' || true)

for subvol in @root @home @swap; do
    if echo "$existing_subvols" | grep -q "^${subvol}$"; then
        warn "Subvolume $subvol already exists, skipping."
    else
        btrfs subvolume create "/mnt/$subvol"
        success "Created subvolume: $subvol"
    fi
done

umount /mnt
success "Subvolumes ready."

# ============================================================
# STEP 7: Mount everything
# ============================================================
header "Step 6: Mounting Filesystems"

info "Mounting @root..."
mount -o subvol=@root,compress=zstd,noatime,space_cache=v2 "$BTRFS_PART" /mnt

mkdir -p /mnt/{boot,home,swap}

info "Mounting @home..."
mount -o subvol=@home,compress=zstd,noatime,space_cache=v2 "$BTRFS_PART" /mnt/home

info "Mounting @swap (nodatacow, no compression)..."
mount -o subvol=@swap,nodatacow,compress=no,noatime,space_cache=v2 "$BTRFS_PART" /mnt/swap

info "Mounting EFI ($EFI_PART)..."
mount "$EFI_PART" /mnt/boot

success "All filesystems mounted."
echo ""
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT "$DISK"
pause

# ============================================================
# STEP 8: Generate hardware config
# ============================================================
header "Step 7: Generating Hardware Configuration"

info "Running nixos-generate-config..."
nixos-generate-config --root /mnt
success "Hardware configuration generated at /mnt/etc/nixos/"

# ============================================================
# STEP 9: Clone flake
# ============================================================
header "Step 8: Cloning NixOS Configuration"

mkdir -p "$(dirname "$INSTALL_DIR")"

if [ -d "$INSTALL_DIR" ]; then
    warn "Directory $INSTALL_DIR already exists."
    if confirm "Remove and re-clone?"; then
        rm -rf "$INSTALL_DIR"
    else
        info "Using existing directory."
    fi
fi

if [ ! -d "$INSTALL_DIR" ]; then
    info "Cloning $REPO_URL (branch: $BRANCH)..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"
git checkout "$BRANCH"
success "Repository ready at $INSTALL_DIR"

# ============================================================
# STEP 10: Prepare hardware-configuration.nix
# ============================================================
header "Step 9: Preparing hardware-configuration.nix"

BTRFS_UUID=$(blkid -s UUID -o value "$BTRFS_PART")
EFI_UUID=$(blkid -s UUID -o value "$EFI_PART")

info "Btrfs UUID: $BTRFS_UUID"
info "EFI UUID:   $EFI_UUID"

# Use the btrfs template
cp hardware-configuration-btrfs.nix hardware-configuration.nix

# Replace placeholder UUIDs
sed -i "s/REPLACE-WITH-YOUR-BTRFS-UUID/$BTRFS_UUID/g" hardware-configuration.nix
sed -i "s/DD75-BF81/$EFI_UUID/g" hardware-configuration.nix

success "UUIDs replaced in hardware-configuration.nix"
echo ""
info "Opening hardware-configuration.nix in nano for review..."
info "Make any changes you need, then save (Ctrl+O) and exit (Ctrl+X)."
pause

nano hardware-configuration.nix

echo ""
info "Final hardware-configuration.nix:"
echo "─────────────────────────────────────"
cat hardware-configuration.nix
echo "─────────────────────────────────────"
echo ""

if ! confirm "Does this look correct? Proceed with installation?"; then
    info "Re-opening nano for edits..."
    nano hardware-configuration.nix
fi

# Stage for flake
git add hardware-configuration.nix
success "hardware-configuration.nix is ready."

# ============================================================
# STEP 11: Install NixOS
# ============================================================
header "Step 10: Installing NixOS"

info "This may take a while (downloading and building packages)..."
echo ""
warn "Do NOT close this terminal or power off during installation!"
echo ""

nixos-install --flake "${INSTALL_DIR}#${HOSTNAME}" --no-root-passwd

success "NixOS installation complete!"

# ============================================================
# STEP 12: Set password and reboot
# ============================================================
header "Step 11: Setting User Password"

info "Set password for user '$USERNAME':"
nixos-enter --root /mnt -c "passwd $USERNAME"

success "Password set."

# ============================================================
# STEP 13: Cleanup and reboot
# ============================================================
header "Step 12: Cleanup & Reboot"

info "Unmounting filesystems..."
cd /
umount -R /mnt

success "Installation complete!"
echo ""
echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║   NixOS has been installed successfully!  ║${NC}"
echo -e "${GREEN}${BOLD}║   The system will now reboot.             ║${NC}"
echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════╝${NC}"
echo ""

if confirm "Reboot now?"; then
    reboot
else
    info "You can reboot manually when ready: reboot"
fi

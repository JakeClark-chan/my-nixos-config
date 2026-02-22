# NixOS Dual Boot Install with Btrfs (alongside Windows)

Manual installation from NixOS live USB on an NVMe SSD with Windows already installed.

> [!CAUTION]
> **Back up your data before proceeding.** Partition resizing carries risk. If you make a mistake with partition numbers, you can destroy your Windows installation.

## 0. Prepare in Windows (Before Booting Live USB)

### Shrink Windows Partition
1. Open **Disk Management** (`diskmgmt.msc`)
2. Right-click your main Windows partition (usually the largest NTFS) → **Shrink Volume**
3. Shrink by your desired NixOS space (minimum ~50 GB recommended)
4. Leave the freed space as **Unallocated** — don't format it

### Note Your EFI Partition
1. In Disk Management, identify the **EFI System Partition** (usually 100–500 MB, FAT32)
2. Note which disk/partition number it is — on NVMe this is typically `/dev/nvme0n1p1`

### Disable Fast Startup
1. **Control Panel** → Power Options → "Choose what the power buttons do"
2. Click "Change settings that are currently unavailable"
3. Uncheck **"Turn on fast startup"** → Save
4. This prevents Windows from locking the EFI partition

---

## 1. Boot NixOS Live USB

Boot the NixOS minimal ISO. Open a terminal — you'll be root. If not, run `sudo -i`.

For tmux:

```bash
# Install tmux
nix-env -iA nixos.tmux

# Start tmux
tmux
```

For detailed instructions, see [install-btrfs.md](install-btrfs.md).

```bash
# Enable networking if 
systemctl start NetworkManager
nmcli device wifi connect "YourWiFi" password "YourPass"  # if needed
```

---

## 2. Identify Your Disk Layout

```bash
lsblk -f
fdisk -l /dev/nvme0n1
```

Typical Windows NVMe layout:
| Partition | Type | Size | Content |
|-----------|------|------|---------|
| `nvme0n1p1` | EFI System (FAT32) | 100–500 MB | Windows Boot Manager |
| `nvme0n1p2` | Microsoft Reserved | 16 MB | MSR |
| `nvme0n1p3` | NTFS | Large | Windows OS |
| `nvme0n1p4` | NTFS | ~1 GB | Windows Recovery |
| (unallocated) | — | Your free space | Will become NixOS |

> [!IMPORTANT]
> **Do NOT touch partitions 1–4.** Only work with the unallocated space.

---

## 3. Choose Your EFI Strategy

### Option A: Share Windows EFI Partition (Recommended)

Simpler, uses the existing EFI partition. GRUB will add itself alongside Windows Boot Manager.

```bash
# No new EFI partition needed — skip to step 4
# Just note the Windows EFI partition (usually /dev/nvme0n1p1)
EFI_PART=/dev/nvme0n1p1
```

### Option B: Create a Separate EFI Partition for NixOS

More isolated — Windows and NixOS each have their own EFI. Requires the unallocated space to be split.

```bash
# Create a 1 GB EFI partition + use the rest for btrfs
# First, find the start of your unallocated space:
fdisk -l /dev/nvme0n1

# Use gdisk or parted to create partitions in the free space
# Replace START with the sector where unallocated space begins
parted /dev/nvme0n1 -- mkpart ESP fat32 START_MB $(( START_MB + 1024 ))MiB
parted /dev/nvme0n1 -- set NEW_PART_NUM esp on
parted /dev/nvme0n1 -- mkpart primary $(( START_MB + 1024 ))MiB 100%

# Format the new EFI partition
mkfs.fat -F 32 -n NIXBOOT /dev/nvme0n1pX  # replace X with your new EFI partition number

EFI_PART=/dev/nvme0n1pX  # your new EFI partition
```

---

## 4. Create the Btrfs Partition

If using **Option A** (shared EFI), create only the btrfs partition in the unallocated space:

```bash
# Find where unallocated space starts
fdisk -l /dev/nvme0n1

# Create btrfs partition in the free space (replace START_MB with actual value)
parted /dev/nvme0n1 -- mkpart primary START_MB 100%

# Format as btrfs (replace pX with your new partition number, e.g. p5)
BTRFS_PART=/dev/nvme0n1pX
mkfs.btrfs -f -L nixos $BTRFS_PART
```

If using **Option B**, you already created the btrfs partition in step 3 — just set:
```bash
BTRFS_PART=/dev/nvme0n1pX  # your btrfs partition from step 3
```

---

## 5. Create Btrfs Subvolumes

```bash
mount $BTRFS_PART /mnt

btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap

umount /mnt
```

---

## 6. Mount Everything

```bash
# Mount @root
mount -o subvol=@root,compress=zstd,noatime,space_cache=v2 $BTRFS_PART /mnt

# Create mount points
mkdir -p /mnt/{boot,home,swap}

# Mount @home
mount -o subvol=@home,compress=zstd,noatime,space_cache=v2 $BTRFS_PART /mnt/home

# Mount @swap (no compression, no CoW)
mount -o subvol=@swap,nodatacow,compress=no,noatime,space_cache=v2 $BTRFS_PART /mnt/swap

# Mount EFI partition
mount $EFI_PART /mnt/boot
```

> [!WARNING]
> If using **Option A** (shared EFI), you'll see Windows Boot Manager files in /mnt/boot. **Do NOT delete them.**

---

## 7. Generate Hardware Config

```bash
nixos-generate-config --root /mnt
```

---

## 8. Clone Your Flake

```bash
nix-env -iA nixos.git

git clone https://github.com/JakeClark-chan/my-nixos-config.git /mnt/home/jc/nixos-config
cd /mnt/home/jc/nixos-config
git checkout niri
```

---

## 9. Update hardware-configuration.nix

```bash
# Use the btrfs template
cp hardware-configuration-btrfs.nix hardware-configuration.nix

# Get your UUIDs
BTRFS_UUID=$(blkid -s UUID -o value $BTRFS_PART)
EFI_UUID=$(blkid -s UUID -o value $EFI_PART)

# Replace placeholder UUIDs
sed -i "s/REPLACE-WITH-YOUR-BTRFS-UUID/$BTRFS_UUID/g" hardware-configuration.nix
sed -i "s/DD75-BF81/$EFI_UUID/g" hardware-configuration.nix

# Verify
cat hardware-configuration.nix

# IMPORTANT: Nix flakes only see Git-tracked files!
git add hardware-configuration.nix
```

---

## 10. Verify GRUB Dual Boot Config

Check that `boot.nix` has OS prober enabled (it should already):

```nix
# modules/core/boot.nix — should contain:
boot.loader.grub = {
  enable = true;
  efiSupport = true;
  device = "nodev";
  useOSProber = true;   # <-- Detects Windows automatically
};
boot.loader.efi.canTouchEfiVariables = true;
```

`useOSProber = true` will auto-detect Windows and add it to the GRUB menu.

---

## 11. Install NixOS

```bash
nixos-install --flake /mnt/home/jc/nixos-config#JakeClark-Sep21st --no-root-passwd
```

---

## 12. Set User Password & Reboot

```bash
nixos-enter --root /mnt -c "passwd jc"

umount -R /mnt
reboot
```

On reboot, GRUB should show both **NixOS** and **Windows Boot Manager**.

---

## Troubleshooting

### Windows not showing in GRUB menu
```bash
# Boot into NixOS, then regenerate GRUB with OS prober
sudo nixos-rebuild switch --flake ~/nixos-config#JakeClark-Sep21st
```
If still missing, check that `os-prober` can see Windows:
```bash
sudo os-prober
# Should output something like: /dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi
```

### Windows clock is wrong after dual booting
NixOS uses UTC by default, Windows uses local time. Fix by telling Windows to use UTC:
```cmd
# In Windows (Admin CMD):
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
```

### GRUB not found after reboot
```bash
# From live USB, mount and chroot
mount -o subvol=@root,compress=zstd $BTRFS_PART /mnt
mount $EFI_PART /mnt/boot
nixos-enter --root /mnt
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=NixOS
exit
reboot
```

### Booting straight to Windows (skipping GRUB)
Enter BIOS/UEFI (usually F2/Del at startup) and set **NixOS** / **GRUB** as the first boot entry above Windows Boot Manager.

# NixOS Clean Install with Btrfs

Manual installation from NixOS live USB, applying the flake directly. Targeting NVMe SSD.

## 1. Boot NixOS Live USB

Boot the NixOS **minimal** ISO. Open a terminal — you'll be root. If not, run `sudo -i`.

### Using tmux for split-pane workflow

Use tmux to view this guide on the left while running commands on the right:

```bash
# Install tmux
nix-env -iA nixpkgs.tmux

# Start tmux
tmux

# Split into left/right panes
# Press: Ctrl+B then %

# LEFT PANE — view this guide
cat /mnt/home/jc/nixos-config/docs/install-btrfs.md | less -N

# Switch to RIGHT PANE: Ctrl+B then →
# Run your install commands here

# Switch back to LEFT PANE: Ctrl+B then ←
```

**Tmux key bindings** (all start with `Ctrl+B`):

| Action | Keys |
|--------|------|
| Split left/right | `Ctrl+B` then `%` |
| Split top/bottom | `Ctrl+B` then `"` |
| Switch pane | `Ctrl+B` then `←` or `→` |
| Enter scroll mode | `Ctrl+B` then `[` |
| Scroll up/down | Arrow keys or `PgUp`/`PgDn` (in scroll mode) |
| Exit scroll mode | `q` |
| Resize pane | `Ctrl+B` hold `Ctrl+←` or `Ctrl+→` |
| Close pane | `exit` or `Ctrl+D` |

```bash
# Enable networking (should be auto)
systemctl start NetworkManager
nmcli device wifi connect "YourWiFi" password "YourPass"  # if needed
```

## 2. Partition the Disk

```bash
# Identify your disk
lsblk

# Wipe and partition
wipefs -a /dev/nvme0n1
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1024MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 1024MiB 100%
```

## 3. Format Partitions

```bash
# EFI partition
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1

# Btrfs root partition
mkfs.btrfs -f -L nixos /dev/nvme0n1p2
```

## 4. Create Btrfs Subvolumes

```bash
# Mount the btrfs partition temporarily
mount /dev/nvme0n1p2 /mnt

# Create subvolumes
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap

# Unmount
umount /mnt
```

## 5. Mount Everything

```bash
# Mount @root subvolume
mount -o subvol=@root,compress=zstd,noatime,space_cache=v2 /dev/nvme0n1p2 /mnt

# Create mount points
mkdir -p /mnt/{boot,home,swap}

# Mount @home subvolume
mount -o subvol=@home,compress=zstd,noatime,space_cache=v2 /dev/nvme0n1p2 /mnt/home

# Mount @swap subvolume (no compression, no CoW)
mount -o subvol=@swap,nodatacow,compress=no,noatime,space_cache=v2 /dev/nvme0n1p2 /mnt/swap

# Mount EFI partition
mount /dev/nvme0n1p1 /mnt/boot
```

## 6. Generate Hardware Config & Get UUIDs

```bash
# Generate hardware-configuration.nix to see your UUIDs
nixos-generate-config --root /mnt

# Note down the btrfs UUID (same for all subvolumes)
blkid /dev/nvme0n1p2
# Example: UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Note down the EFI UUID
blkid /dev/nvme0n1p1
# Example: UUID="XXXX-XXXX"
```

## 7. Clone Your Flake

```bash
# Install git in the live environment
nix-env -iA nixos.git

# Clone your config
git clone https://github.com/JakeClark-chan/my-nixos-config.git /mnt/home/jc/nixos-config
cd /mnt/home/jc/nixos-config

# Switch to niri branch
git checkout niri
```

## 8. Update hardware-configuration.nix

Use the pre-configured btrfs template (has correct mount options + @swap subvolume) instead of the auto-generated one:

```bash
# Use the btrfs template (already has correct subvol options, nodatacow for swap, etc.)
cp hardware-configuration-btrfs.nix hardware-configuration.nix

# Get your UUIDs
BTRFS_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
EFI_UUID=$(blkid -s UUID -o value /dev/nvme0n1p1)

# Replace placeholder UUIDs
sed -i "s/REPLACE-WITH-YOUR-BTRFS-UUID/$BTRFS_UUID/g" hardware-configuration.nix
sed -i "s/DD75-BF81/$EFI_UUID/g" hardware-configuration.nix

# Verify it looks correct
cat hardware-configuration.nix

# IMPORTANT: Nix flakes only see Git-tracked files!
git add hardware-configuration.nix
```

> [!NOTE]
> The auto-generated `nixos-generate-config` may miss `space_cache=v2`, the `@swap` subvolume, and `nodatacow`. That's why we use the pre-configured template.

## 9. Install NixOS with Your Flake

```bash
# Install NixOS using your flake
nixos-install --flake /mnt/home/jc/nixos-config#JakeClark-Sep21st --no-root-passwd
```

> Replace `JakeClark-Sep21st` with your actual hostname from `system-settings.nix`.

## 10. Set User Password & Reboot

```bash
# Set your user password
nixos-enter --root /mnt -c "passwd jc"

# Unmount and reboot
umount -R /mnt
reboot
```

## Troubleshooting

### GRUB not found after reboot
```bash
# From live USB, mount and chroot
mount -o subvol=@root,compress=zstd /dev/nvme0n1p2 /mnt
mount /dev/nvme0n1p1 /mnt/boot
nixos-enter --root /mnt
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=NixOS
```

### VirtualBox: Enable EFI
In VirtualBox settings → System → check **"Enable EFI (special OSes only)"** before booting.

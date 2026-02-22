# NixOS Clean Install with Btrfs (VirtualBox)

Manual installation from NixOS live USB, applying the flake directly.

## 1. Boot NixOS Live USB

Boot the NixOS minimal ISO in VirtualBox. Open a terminal — you'll be root.

```bash
# Enable networking (should be auto)
systemctl start NetworkManager
nmcli device wifi connect "YourWiFi" password "YourPass"  # if needed
```

## 2. Partition the Disk

```bash
# Identify your disk (usually /dev/sda in VirtualBox)
lsblk

# Wipe and partition
wipefs -a /dev/sda
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 512MiB 100%
```

## 3. Format Partitions

```bash
# EFI partition
mkfs.fat -F 32 -n BOOT /dev/sda1

# Btrfs root partition
mkfs.btrfs -f -L nixos /dev/sda2
```

## 4. Create Btrfs Subvolumes

```bash
# Mount the btrfs partition temporarily
mount /dev/sda2 /mnt

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
mount -o subvol=@root,compress=zstd,noatime,space_cache=v2 /dev/sda2 /mnt

# Create mount points
mkdir -p /mnt/{boot,home,swap}

# Mount @home subvolume
mount -o subvol=@home,compress=zstd,noatime,space_cache=v2 /dev/sda2 /mnt/home

# Mount @swap subvolume (no compression, no CoW)
mount -o subvol=@swap,nodatacow,compress=no,noatime,space_cache=v2 /dev/sda2 /mnt/swap

# Mount EFI partition
mount /dev/sda1 /mnt/boot
```

## 6. Generate Hardware Config & Get UUIDs

```bash
# Generate hardware-configuration.nix to see your UUIDs
nixos-generate-config --root /mnt

# Note down the btrfs UUID (same for all subvolumes)
blkid /dev/sda2
# Example: UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Note down the EFI UUID
blkid /dev/sda1
# Example: UUID="XXXX-XXXX"
```

## 7. Clone Your Flake

```bash
# Install git in the live environment
nix-env -iA nixos.git

# Clone your config
git clone https://github.com/JakeClark38a/my-nixos-config.git /mnt/home/jc/nixos-config
cd /mnt/home/jc/nixos-config

# Switch to niri branch
git checkout niri
```

## 8. Update UUIDs in hardware-configuration.nix

```bash
# Edit hardware-configuration.nix with the correct UUIDs from step 6
nano hardware-configuration.nix
```

Replace all `REPLACE-WITH-YOUR-BTRFS-UUID` with your actual btrfs UUID, and update the EFI UUID.

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
mount -o subvol=@root,compress=zstd /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot
nixos-enter --root /mnt
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=NixOS
```

### VirtualBox: Enable EFI
In VirtualBox settings → System → check **"Enable EFI (special OSes only)"** before booting.

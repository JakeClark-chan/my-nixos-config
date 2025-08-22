{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Kernel parameters to reduce boot noise and improve compatibility
  boot.kernelParams = [
    # Reduce ACPI verbosity
    "acpi.debug_level=0x2"
    # Suppress some harmless warnings
    "loglevel=4"
    # Improve Intel graphics compatibility
    "i915.modeset=1"
  ];
}

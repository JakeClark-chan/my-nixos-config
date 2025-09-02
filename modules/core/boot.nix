{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    # configurationLimit = 10;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel parameters to reduce boot noise and improve compatibility
  boot.kernelParams = [ "i915.modeset=1" ];
}

# Core system modules - Essential system settings
{
  imports = [
    ./boot.nix      # Bootloader configuration
    ./nix.nix       # Nix settings, flakes, GC
    ./hardware.nix  # Hardware-specific configs
  ];
}

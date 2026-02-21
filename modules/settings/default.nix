# System settings - Non-core system configurations
{
  imports = [
    ./locale.nix    # Timezone, language, input methods
    ./memory.nix    # Swap and memory management
    ./btrfs.nix     # Btrfs maintenance (scrub, balance, fstrim)
    ./journald.nix  # System logging configuration
    ./plymouth.nix  # Boot splash screen
  ];
}

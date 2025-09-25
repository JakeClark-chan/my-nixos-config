{
  # Import modular configurations
  imports = [
    ./packages.nix    # Package installations
    ./launchers.nix   # Desktop entries and launchers
    ./programs.nix    # Program configurations (git, kitty, gtk, qt, etc.)
    ./services.nix    # User services and systemd services
    ./files.nix       # File configurations and session variables
    ./hyprland.nix    # Hyprland window manager settings
  ];
}
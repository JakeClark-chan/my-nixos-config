{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:

{
  # Import modular configurations
  imports = [
    ./jc/packages.nix    # Package installations
    ./jc/launchers.nix   # Desktop entries and launchers
    ./jc/programs.nix    # Program configurations (git, kitty, gtk, qt, etc.)
    ./jc/services.nix    # User services and systemd services
    ./jc/files.nix       # File configurations and session variables
  ];

  # Basic home-manager configuration
  home.username = systemSettings.username;
  home.homeDirectory = systemSettings.homeDirectory;
  home.stateVersion = "25.11";
}

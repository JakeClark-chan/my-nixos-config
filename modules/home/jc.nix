{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:

{
  # Import modular configurations
  imports = [
    ./jc
  ];

  # Basic home-manager configuration
  home.username = systemSettings.username;
  home.homeDirectory = systemSettings.homeDirectory;
  home.stateVersion = "25.11";
}

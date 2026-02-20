{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:

{
  # Niri compositor configuration
  # The config.kdl is managed in modules/home/.config/niri/config.kdl
  # and loaded as a raw KDL string via niri-flake's programs.niri.config
  programs.niri.config = builtins.readFile ../../.config/niri/config.kdl;
}

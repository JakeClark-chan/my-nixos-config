{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:

{
  # Niri compositor configuration
  # The config.kdl is loaded via xdg.configFile from modules/home/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".source = ../../.config/niri/config.kdl;
}

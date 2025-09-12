{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:
let
  shutdownScript = pkgs.callPackage ../scripts/graceful-shutdown.nix {};
in
{
  # User services configuration
  services = {
    # Swaync notification daemon
    swaync = {
      enable = false;  # Disabled - will be started by Hyprland instead
      settings = {
        positionX = "right";
        positionY = "top";
        "layer" = "top";
        "control-center-layer" = "overlay";
        "layer-shell" = true;
        "cssPriority" = "user";
        "control-center-width" = 500;
        "control-center-height" = 600;
        "notification-window-width" = 400;
        "keyboard-shortcuts" = true;
        "image-visibility" = "when-available";
        "transition-time" = 200;
        "hide-on-action" = true;
        "hide-on-empty" = false;
        "widgets" = [ "title" "dnd" "notifications" "mpris" ];
        "widget-config" = {
          "title" = {
            "text" = " Notifications";
            "clear-all-button" = true;
            "button-text" = "Clear All";
          };
          "dnd" = {
            "text" = "Do Not Disturb";
          };
          "notifications" = {
            "label" = "Notifications";
            "actions" = ["default" "open"];
          };
          "mpris" = {
            "label" = "Media Player";
            "actions" = ["play-pause" "next" "previous"];
          };
        };
      };
    };
  };

  # Systemd user services configuration
  systemd.user.services = {
  };
}

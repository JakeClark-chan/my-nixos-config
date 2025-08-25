{ pkgs }:

pkgs.writeShellScriptBin "lock-screen" ''
  #!/bin/bash
  # Beautiful lock screen script with options

  # Function to show menu
  show_menu() {
      choice=$(echo -e "Hyprlock (Recommended)\nSwaylock Effects\nCancel" | \
          ${pkgs.wofi}/bin/wofi --dmenu \
               --prompt "Choose Lock Screen:" \
               --width 300 \
               --height 150 \
               --cache-file /dev/null)
      
      case "$choice" in
          "Hyprlock (Recommended)")
              ${pkgs.hyprlock}/bin/hyprlock
              ;;
          "Swaylock Effects")
              swaylock
              ;;
          "Cancel"|"")
              exit 0
              ;;
      esac
  }

  # If argument provided, use directly
  case "$1" in
      "hyprlock")
          ${pkgs.hyprlock}/bin/hyprlock
          ;;
      "swaylock")
          swaylock
          ;;
      "menu")
          show_menu
          ;;
      *)
          # Default to hyprlock (recommended for Hyprland)
          ${pkgs.hyprlock}/bin/hyprlock
          ;;
  esac
''

{ pkgs }:

pkgs.writeShellScriptBin "lock-screen" ''
  #!/bin/bash
  # Lock screen script using hyprlock only

  # Function to show confirmation (optional)
  show_menu() {
      choice=$(echo -e "Lock Screen\nCancel" | \
          ${pkgs.wofi}/bin/wofi --dmenu \
               --prompt "Lock Screen:" \
               --width 250 \
               --height 100 \
               --cache-file /dev/null)
      
      case "$choice" in
          "Lock Screen")
              ${pkgs.hyprlock}/bin/hyprlock
              ;;
          "Cancel"|"")
              exit 0
              ;;
      esac
  }

  # If argument provided, use directly
  case "$1" in
      "hyprlock"|"")
          ${pkgs.hyprlock}/bin/hyprlock
          ;;
      "menu")
          show_menu
          ;;
      *)
          # Default to hyprlock
          ${pkgs.hyprlock}/bin/hyprlock
          ;;
  esac
''

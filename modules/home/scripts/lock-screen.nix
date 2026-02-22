{ pkgs }:

pkgs.writeShellScriptBin "lock-screen" ''
  #!/bin/bash
  # Lock screen script using loginctl (compatible with Niri)

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
              loginctl lock-session
              ;;
          "Cancel"|"")
              exit 0
              ;;
      esac
  }

  # If argument provided, use directly
  case "$1" in
      "lock"|"")
          loginctl lock-session
          ;;
      "menu")
          show_menu
          ;;
      *)
          # Default to loginctl lock
          loginctl lock-session
          ;;
  esac
''

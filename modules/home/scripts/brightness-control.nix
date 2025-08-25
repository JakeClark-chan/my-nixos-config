{ pkgs }:

pkgs.writeShellScriptBin "brightness-control" ''
  #!/bin/bash
  case "$1" in
    "up")
      ${pkgs.brightnessctl}/bin/brightnessctl set 5%+
      ;;
    "down")
      ${pkgs.brightnessctl}/bin/brightnessctl set 5%-
      ;;
  esac
  
  # Get current brightness percentage
  BRIGHTNESS=$(${pkgs.brightnessctl}/bin/brightnessctl get)
  MAX_BRIGHTNESS=$(${pkgs.brightnessctl}/bin/brightnessctl max)
  PERCENTAGE=$((BRIGHTNESS * 100 / MAX_BRIGHTNESS))
  
  ${pkgs.libnotify}/bin/notify-send -t 2000 -h string:x-canonical-private-synchronous:brightness "Brightness" "$PERCENTAGE%" -i display-brightness
''

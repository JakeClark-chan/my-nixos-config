{ pkgs }:

pkgs.writeShellScriptBin "volume-control" ''
  #!/bin/bash
  case "$1" in
    "up")
      ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+
      ;;
    "down")
      ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-
      ;;
    "mute")
      ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      ;;
  esac
  
  # Get current volume and mute status
  VOLUME=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
  MUTED=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED" || echo "")
  
  if [ "$MUTED" = "MUTED" ]; then
    ${pkgs.libnotify}/bin/notify-send -t 2000 -h string:x-canonical-private-synchronous:volume "Volume" "Muted" -i audio-volume-muted
  else
    ${pkgs.libnotify}/bin/notify-send -t 2000 -h string:x-canonical-private-synchronous:volume "Volume" "$VOLUME%" -i audio-volume-high
  fi
''

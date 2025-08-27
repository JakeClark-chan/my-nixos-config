{ pkgs, config }:

pkgs.writeShellScriptBin "apply-home-manager" ''
  #!/usr/bin/env bash
  set -x

  # Home Manager Apply Script with Notifications
  # This script applies Home Manager configuration with visual feedback

  # Function to send notification
  notify() {
      local title="$1"
      local message="$2"
      local urgency="$3"
      
      # Use swaync if available, fallback to notify-send
      if command -v ${pkgs.swaynotificationcenter}/bin/swaync-client &> /dev/null; then
          ${pkgs.swaynotificationcenter}/bin/swaync-client -t "$title" -b "$message" ''${urgency:+-u $urgency}
      elif command -v ${pkgs.libnotify}/bin/notify-send &> /dev/null; then
          ${pkgs.libnotify}/bin/notify-send ''${urgency:+-u $urgency} "$title" "$message"
      else
          echo "$title: $message"
      fi
  }

  # Change to the config directory
  cd /home/jc/nixos-config || {
      notify "Home Manager Error" "Could not change to config directory" "critical"
      exit 1
  }

  # Send starting notification
  notify "Home Manager" "Applying configuration..." "normal"

  # Apply Home Manager configuration
  if ${pkgs.home-manager}/bin/home-manager switch --flake .; then
      notify "Home Manager" "Configuration applied successfully!" "normal"
  else
      notify "Home Manager Error" "Failed to apply configuration" "critical"
      exit 1
  fi
''

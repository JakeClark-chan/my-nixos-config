{ pkgs }:

pkgs.writeShellScriptBin "graceful-shutdown" ''
  #!/bin/bash
  
  ACTION="$1"  # "shutdown" or "reboot"
  
  if [ -z "$ACTION" ]; then
      echo "Usage: graceful-shutdown [shutdown|reboot]"
      exit 1
  fi
  
  # Function to get running applications with windows (using niri msg)
  get_running_apps() {
      ${pkgs.niri}/bin/niri msg windows 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP 'app_id: "\K[^"]+' | sort -u
  }
  
  # Function to show blocking apps dialog
  show_blocking_dialog() {
      local apps="$1"
      local action="$2"
      
      dialog_text="The following applications are preventing $action:\\n\\n$apps\\n\\nWhat would you like to do?"
      
      choice=$(echo -e "Wait for apps to close\nForce close all apps\nCancel $action" | \
          ${pkgs.wofi}/bin/wofi --dmenu \
               --prompt "Applications preventing $action:" \
               --width 400 \
               --height 200 \
               --cache-file /dev/null)
      
      case "$choice" in
          "Wait for apps to close")
              return 1  # Continue waiting
              ;;
          "Force close all apps")
              return 0  # Force close
              ;;
          *)
              return 2  # Cancel
              ;;
      esac
  }
  
  # Function to force close all applications
  force_close_apps() {
      echo "Force closing all applications..."
      
      # Close all windows via niri
      ${pkgs.niri}/bin/niri msg action close-window 2>/dev/null || true
      
      sleep 2
      
      # Force kill any remaining processes if needed
      pkill -f "firefox|code|vlc|kitty|cosmic-term" 2>/dev/null || true
  }
  
  # Function to gracefully close applications
  graceful_close_apps() {
      echo "Attempting graceful shutdown of applications..."
      
      # Send close signals via niri - close focused window repeatedly
      for i in $(seq 1 20); do
          ${pkgs.niri}/bin/niri msg action close-window 2>/dev/null || break
          sleep 0.3
      done
  }
  
  # Main shutdown logic
  echo "Initiating graceful $ACTION..."
  
  # First attempt: graceful close
  graceful_close_apps
  
  # Wait up to 30 seconds for apps to close
  timeout=30
  while [ $timeout -gt 0 ]; do
      running_apps=$(get_running_apps)
      
      if [ -z "$running_apps" ]; then
          echo "All applications closed successfully."
          break
      fi
      
      echo "Waiting for applications to close... ($timeout seconds remaining)"
      echo "Running apps: $running_apps"
      sleep 1
      timeout=$((timeout - 1))
  done
  
  # Check if apps are still running
  running_apps=$(get_running_apps)
  if [ -n "$running_apps" ]; then
      echo "Some applications are still running:"
      echo "$running_apps"
      
      # Show dialog to user
      if show_blocking_dialog "$running_apps" "$ACTION"; then
          force_close_apps
          sleep 2
      else
          exit_code=$?
          if [ $exit_code -eq 2 ]; then
              echo "$ACTION cancelled by user."
              exit 0
          fi
          # If return code is 1, continue waiting
          echo "Continuing to wait for applications..."
          exit 0
      fi
  fi
  
  # Proceed with shutdown/reboot
  echo "Proceeding with $ACTION..."
  if [ "$ACTION" = "shutdown" ]; then
      systemctl poweroff
  elif [ "$ACTION" = "reboot" ]; then
      systemctl reboot
  fi
''

{ pkgs }:

pkgs.writeShellScriptBin "graceful-shutdown" ''
  #!/bin/bash
  
  ACTION="$1"  # "shutdown", "reboot", or "logout"
  
  if [ -z "$ACTION" ]; then
      echo "Usage: graceful-shutdown [shutdown|reboot|logout]"
      exit 1
  fi
  
  # Get current user info
  CURRENT_USER="$(whoami)"
  CURRENT_UID="$(id -u)"
  
  # Function to get running applications with windows
  get_running_apps() {
      ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.workspace.id != -99) | .class' | sort -u
  }
  
  # Function to get all user processes
  get_user_processes() {
      ps -u "$CURRENT_USER" -o pid,comm --no-headers | grep -v "^[[:space:]]*$$" | grep -v "graceful-shutdown"
  }
  
  # Function to get critical user processes that should be handled carefully
  get_critical_processes() {
      ps -u "$CURRENT_USER" -o pid,comm --no-headers | grep -E "(ssh|tmux|screen|nvim|vim|emacs|code)" | awk '{print $1}'
  }
  
  # Function to save user session data
  save_user_session() {
      echo "Saving user session data..."
      
      # Save shell history
      history -w 2>/dev/null || true
      
      # Sync any pending file operations
      sync
      
      # Save any open editor sessions (if supported)
      # For nvim with session support
      if pgrep -u "$CURRENT_USER" nvim >/dev/null; then
          echo "Saving Neovim sessions..."
          pkill -USR1 -u "$CURRENT_USER" nvim 2>/dev/null || true
      fi
      
      # For VS Code, try to save workspace
      if pgrep -u "$CURRENT_USER" code >/dev/null; then
          echo "Attempting to save VS Code workspace..."
          # VS Code should auto-save, but we give it a moment
          sleep 1
      fi
      
      echo "Session data saved."
  }
  
  # Function to show blocking apps dialog
  show_blocking_dialog() {
      local apps="$1"
      local processes="$2"
      local action="$3"
      
      dialog_text="The following applications and processes are preventing $action:\\n\\nApplications:\\n$apps\\n\\nProcesses: $processes\\n\\nWhat would you like to do?"
      
      choice=$(echo -e "Wait for apps to close\nSave & force close all\nForce close immediately\nCancel $action" | \
          ${pkgs.wofi}/bin/wofi --dmenu \
               --prompt "Applications preventing $action:" \
               --width 500 \
               --height 250 \
               --cache-file /dev/null)
      
      case "$choice" in
          "Wait for apps to close")
              return 1  # Continue waiting
              ;;
          "Save & force close all")
              return 0  # Save and force close
              ;;
          "Force close immediately")
              return 3  # Force close without saving
              ;;
          *)
              return 2  # Cancel
              ;;
      esac
  }
  
  # Function to gracefully close user processes
  graceful_close_processes() {
      echo "Gracefully closing user processes..."
      
      # First, close GUI applications through Hyprland
      ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.workspace.id != -99) | .address' | while read addr; do
          ${pkgs.hyprland}/bin/hyprctl dispatch closewindow address:$addr
      done
      
      # Close background processes gracefully
      echo "Sending SIGTERM to user processes..."
      
      # Get all user processes except critical system ones
      user_pids=$(ps -u "$CURRENT_USER" -o pid --no-headers | grep -v "^[[:space:]]*$$" | grep -v "graceful-shutdown" | tr '\n' ' ')
      
      if [ -n "$user_pids" ]; then
          # Send SIGTERM to all user processes
          for pid in $user_pids; do
              if kill -0 "$pid" 2>/dev/null; then
                  kill -TERM "$pid" 2>/dev/null || true
              fi
          done
      fi
      
      echo "Graceful close signals sent."
  }
  
  # Function to force close all user processes
  force_close_processes() {
      local save_first="$1"
      
      if [ "$save_first" = "true" ]; then
          save_user_session
          sleep 2
      fi
      
      echo "Force closing all user processes..."
      
      # Force close GUI applications first
      ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.workspace.id != -99) | .address' | while read addr; do
          ${pkgs.hyprland}/bin/hyprctl dispatch closewindow address:$addr
      done
      
      sleep 2
      
      # Force kill all user processes
      echo "Force killing remaining user processes..."
      
      # Get all user processes
      user_pids=$(ps -u "$CURRENT_USER" -o pid --no-headers | grep -v "^[[:space:]]*$$" | grep -v "graceful-shutdown")
      
      if [ -n "$user_pids" ]; then
          # First try SIGKILL for each process
          for pid in $user_pids; do
              if kill -0 "$pid" 2>/dev/null; then
                  kill -KILL "$pid" 2>/dev/null || true
              fi
          done
          
          sleep 1
          
          # Fallback: use pkill for any remaining processes
          pkill -KILL -u "$CURRENT_USER" 2>/dev/null || true
      fi
      
      echo "All user processes terminated."
  }
  
  # Function to check for running processes
  check_running_processes() {
      local running_apps=$(get_running_apps)
      local running_procs=$(get_user_processes | wc -l)
      
      echo "running_apps=$running_apps"
      echo "running_procs=$running_procs"
  }
  
  # Function to perform logout
  perform_logout() {
      echo "Performing logout..."
      
      # Close all user processes
      graceful_close_processes
      sleep 3
      
      # Force close any remaining processes
      force_close_processes false
      
      # Exit Hyprland session
      ${pkgs.hyprland}/bin/hyprctl dispatch exit
  }
  
  # Main shutdown logic
  echo "Initiating graceful $ACTION..."
  
  # Handle logout separately
  if [ "$ACTION" = "logout" ]; then
      perform_logout
      exit 0
  fi
  
  # For shutdown/reboot: first attempt graceful close
  graceful_close_processes
  
  # Wait up to 30 seconds for processes to close
  timeout=30
  while [ $timeout -gt 0 ]; do
      running_apps=$(get_running_apps)
      running_procs=$(get_user_processes | wc -l)
      
      if [ -z "$running_apps" ] && [ "$running_procs" -le 2 ]; then
          echo "All applications and processes closed successfully."
          break
      fi
      
      echo "Waiting for applications and processes to close... ($timeout seconds remaining)"
      if [ -n "$running_apps" ]; then
          echo "Running apps: $running_apps"
      fi
      echo "Active user processes: $running_procs"
      
      sleep 1
      timeout=$((timeout - 1))
  done
  
  # Check if apps/processes are still running
  running_apps=$(get_running_apps)
  running_procs=$(get_user_processes)
  running_proc_count=$(echo "$running_procs" | wc -l)
  
  if [ -n "$running_apps" ] || [ "$running_proc_count" -gt 2 ]; then
      echo "Some applications or processes are still running:"
      if [ -n "$running_apps" ]; then
          echo "Applications: $running_apps"
      fi
      echo "User processes ($running_proc_count):"
      echo "$running_procs" | head -10  # Show first 10 processes
      
      # Show dialog to user
      show_blocking_dialog "$running_apps" "$running_procs" "$ACTION"
      dialog_result=$?
      
      case $dialog_result in
          0)  # Save and force close
              force_close_processes true
              sleep 3
              ;;
          3)  # Force close immediately
              force_close_processes false
              sleep 3
              ;;
          2)  # Cancel
              echo "$ACTION cancelled by user."
              exit 0
              ;;
          1)  # Continue waiting
              echo "Continuing to wait for applications..."
              exit 0
              ;;
      esac
  fi
  
  # Final cleanup - ensure all user processes are terminated
  echo "Performing final cleanup..."
  remaining_procs=$(get_user_processes | wc -l)
  if [ "$remaining_procs" -gt 2 ]; then
      echo "Force terminating remaining $remaining_procs user processes..."
      pkill -KILL -u "$CURRENT_USER" 2>/dev/null || true
      sleep 1
  fi
  
  # Proceed with shutdown/reboot
  echo "Proceeding with $ACTION..."
  case "$ACTION" in
      "shutdown")
          systemctl poweroff
          ;;
      "reboot")
          systemctl reboot
          ;;
      *)
          echo "Unknown action: $ACTION"
          exit 1
          ;;
  esac
''

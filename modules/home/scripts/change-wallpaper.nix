{ pkgs }:

pkgs.writeShellScriptBin "change-wallpaper" ''
  #!/usr/bin/env bash

  # Directory containing the wallpapers
  WALLPAPER_DIR="$HOME/nixos-config/backgrounds"
  # File to store the last used wallpaper index for linear mode
  LAST_INDEX_FILE="$HOME/.cache/current_wallpaper_index"

  # Ensure cache directory exists
  mkdir -p "$HOME/.cache"

  # Function to display notifications
  notify() {
      ${pkgs.libnotify}/bin/notify-send -t 2000 "$1" "$2" --icon=preferences-desktop-wallpaper
  }

  # Find all wallpapers in the directory
  wallpapers=($(${pkgs.findutils}/bin/find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.webp" \)))
  wallpaper_count=$(( ''${#wallpapers[@]} ))

  if [ "$wallpaper_count" -eq 0 ]; then
      notify "❌ Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
      exit 1
  fi

  # Default to linear mode, use first argument if provided (e.g., "random")
  MODE="''${1:-linear}"
  
  next_wallpaper=""

  if [ "$MODE" = "random" ]; then
      # --- Random Mode ---
      random_index=$(( RANDOM % wallpaper_count ))
      next_wallpaper="''${wallpapers[random_index]}"

  else
      # --- Linear Mode (default) ---
      last_index=-1
      if [ -f "$LAST_INDEX_FILE" ]; then
          last_index=$(${pkgs.coreutils}/bin/cat "$LAST_INDEX_FILE")
      fi
      
      next_index=$(( (last_index + 1) % wallpaper_count ))
      next_wallpaper="''${wallpapers[next_index]}"
      
      # Save the new index
      echo "$next_index" > "$LAST_INDEX_FILE"
  fi

  if [ -z "$next_wallpaper" ]; then
      notify "❌ Wallpaper Error" "Could not determine the next wallpaper."
      exit 1
  fi

  # Change the wallpaper using swaybg
  # Kill any existing swaybg instance, then start a new one
  ${pkgs.procps}/bin/pkill swaybg 2>/dev/null || true
  ${pkgs.swaybg}/bin/swaybg -i "$next_wallpaper" -m fill &
  disown

  wallpaper_name=$(${pkgs.coreutils}/bin/basename "$next_wallpaper")
  notify "✅ Wallpaper Changed" "Now displaying: $wallpaper_name"
''

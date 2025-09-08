{ pkgs, ... }:

pkgs.writeShellScriptBin "hyprland-keybinds" ''
  #!/usr/bin/env bash
  
  # Hyprland Keybinds Browser - Interactive keybinding viewer and executor
  # Usage: hyprland-keybinds [config_path]
  
  CONFIG_FILE="''${1:-$HOME/.config/hypr/hyprland.conf}"
  TEMP_FILE="/tmp/hypr_keybinds_$$"
  
  # Function to parse modifier combinations
  parse_modifiers() {
    local mods="$1"
    local result=""
    
    # Replace common modifier variables
    mods="''${mods//\$mainMod/SUPER}"
    mods="''${mods//\$mod/SUPER}"
    
    # Handle multiple modifiers
    if [[ "$mods" == *"CTRL"* ]]; then
      result+="Ctrl+"
    fi
    if [[ "$mods" == *"ALT"* ]]; then
      result+="Alt+"
    fi
    if [[ "$mods" == *"SHIFT"* ]]; then
      result+="Shift+"
    fi
    if [[ "$mods" == *"SUPER"* ]] || [[ "$mods" == *"WIN"* ]] || [[ "$mods" == *"CMD"* ]]; then
      result+="Win+"
    fi
    
    echo "$result"
  }
  
  # Function to parse key names and make them human-readable
  parse_keyname() {
    local key="$1"
    
    case "$key" in
      "Return") echo "Enter" ;;
      "grave") echo "\`" ;;
      "comma") echo "," ;;
      "period") echo "." ;;
      "slash") echo "/" ;;
      "semicolon") echo ";" ;;
      "apostrophe") echo "'" ;;
      "bracketleft") echo "[" ;;
      "bracketright") echo "]" ;;
      "backslash") echo "\\" ;;
      "minus") echo "-" ;;
      "equal") echo "=" ;;
      "space") echo "Space" ;;
      "Tab") echo "Tab" ;;
      "Escape") echo "Esc" ;;
      "BackSpace") echo "Backspace" ;;
      "Delete") echo "Del" ;;
      "Insert") echo "Ins" ;;
      "Home") echo "Home" ;;
      "End") echo "End" ;;
      "Page_Up") echo "PgUp" ;;
      "Page_Down") echo "PgDn" ;;
      "Up") echo "↑" ;;
      "Down") echo "↓" ;;
      "Left") echo "←" ;;
      "Right") echo "→" ;;
      "XF86AudioRaiseVolume") echo "Vol+" ;;
      "XF86AudioLowerVolume") echo "Vol-" ;;
      "XF86AudioMute") echo "Mute" ;;
      "XF86AudioMicMute") echo "Mic Mute" ;;
      "XF86MonBrightnessUp") echo "Brightness+" ;;
      "XF86MonBrightnessDown") echo "Brightness-" ;;
      "XF86AudioNext") echo "Next Track" ;;
      "XF86AudioPrev") echo "Prev Track" ;;
      "XF86AudioPlay") echo "Play/Pause" ;;
      "XF86AudioPause") echo "Play/Pause" ;;
      "mouse:272") echo "Left Click" ;;
      "mouse:273") echo "Right Click" ;;
      "mouse_down") echo "Scroll Down" ;;
      "mouse_up") echo "Scroll Up" ;;
      *) echo "$key" ;;
    esac
  }
  
  # Function to parse and format descriptions from comments
  parse_description() {
    local line="$1"
    local default_desc="$2"
    
    # Look for comment with description
    if [[ "$line" == *"#"* ]]; then
      local comment="''${line#*#}"
      comment="''${comment## }"  # Remove leading spaces
      # Clean up common prefixes
      comment="''${comment#Win + }"
      comment="''${comment#Ctrl + }"
      comment="''${comment#Alt + }"
      echo "$comment"
    else
      echo "$default_desc"
    fi
  }
  
  # Function to categorize bindings
  categorize_binding() {
    local cmd="$1"
    local key="$2"
    
    case "$cmd" in
      *"workspace"*) echo "🏢 Workspaces" ;;
      *"movetoworkspace"*) echo "📦 Move Windows" ;;
      *"movefocus"*|*"movewindow"*) echo "🔄 Window Management" ;;
      *"resizeactive"*|*"togglesplit"*|*"togglefloating"*) echo "📐 Window Layout" ;;
      *"exec"*) 
        case "$cmd" in
          *"terminal"*|*"kitty"*) echo "💻 Applications" ;;
          *"menu"*|*"wofi"*|*"launcher"*) echo "🚀 Launchers" ;;
          *"volume"*|*"brightness"*) echo "🔧 System Controls" ;;
          *"wallpaper"*|*"lock"*|*"shutdown"*) echo "⚙️ System" ;;
          *"display"*|*"monitor"*|*"hdmi"*) echo "🖥️ Display" ;;
          *) echo "💻 Applications" ;;
        esac ;;
      *"submap"*) echo "🗂️ Submaps" ;;
      *"killactive"*|*"exit"*|*"fullscreen"*) echo "🪟 Window Control" ;;
      *) echo "⌨️ Other" ;;
    esac
  }
  
  # Function to extract keybindings from config
  extract_keybinds() {
    local config_file="$1"
    local in_submap=""
    local current_category=""
    
    echo "# 🎯 Hyprland Keybindings Reference" > "$TEMP_FILE"
    echo "# Select a keybinding and press Enter to execute it" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    
    while IFS= read -r line; do
      # Skip empty lines and pure comments
      [[ -z "''${line// }" ]] && continue
      [[ "''${line// }" =~ ^#.*$ ]] && continue
      
      # Track submap context
      if [[ "$line" =~ ^[[:space:]]*submap[[:space:]]*=[[:space:]]*([^[:space:]]+) ]]; then
        local submap_name="''${BASH_REMATCH[1]}"
        if [[ "$submap_name" != "reset" ]]; then
          in_submap="$submap_name"
          echo "" >> "$TEMP_FILE"
          echo "## 🗂️ Submap: $submap_name" >> "$TEMP_FILE"
        else
          in_submap=""
        fi
        continue
      fi
      
      # Parse bind statements
      if [[ "$line" =~ ^[[:space:]]*(bind[elm]*)[[:space:]]*=[[:space:]]*([^,]+),[[:space:]]*([^,]+),[[:space:]]*(.+)$ ]]; then
        local bind_type="''${BASH_REMATCH[1]}"
        local modifiers="''${BASH_REMATCH[2]// }"
        local key="''${BASH_REMATCH[3]// }"
        local command="''${BASH_REMATCH[4]}"
        
        # Parse modifiers and key
        local mod_string=$(parse_modifiers "$modifiers")
        local key_string=$(parse_keyname "$key")
        local full_key="''${mod_string}''${key_string}"
        
        # Add submap prefix if we're in one
        if [[ -n "$in_submap" ]]; then
          full_key="[$in_submap] $key_string"
        fi
        
        # Get description from comment or generate one
        local description=$(parse_description "$line" "Execute: $command")
        
        # Categorize the binding
        local category=$(categorize_binding "$command" "$key")
        
        # Create the display line
        local display_line="$full_key|$description|$command"
        
        # Add category header if it's different from current
        if [[ "$category" != "$current_category" ]] && [[ -z "$in_submap" ]]; then
          current_category="$category"
          echo "" >> "$TEMP_FILE"
          echo "## $category" >> "$TEMP_FILE"
        fi
        
        echo "$display_line" >> "$TEMP_FILE"
      fi
    done < "$config_file"
  }
  
  # Function to show wofi menu and handle selection
  show_keybind_menu() {
    local selected
    
    # Create formatted display for wofi
    local wofi_input=""
    while IFS='|' read -r keybind desc command; do
      # Skip headers and empty lines
      [[ "$keybind" =~ ^#.*$ ]] && continue
      [[ "$keybind" =~ ^##.*$ ]] && continue
      [[ -z "$keybind" ]] && continue
      
      # Format: "Key Combination: Description"
      local formatted_line="$(printf "%-20s: %s" "$keybind" "$desc")"
      wofi_input+="$formatted_line"$'\n'
    done < "$TEMP_FILE"
    
    # Show wofi menu
    selected=$(echo "$wofi_input" | wofi \
      --dmenu \
      --prompt "Hyprland Keybindings" \
      --lines 15 \
      --width 800 \
      --height 600 \
      --matching fuzzy \
      --insensitive \
      --allow-markup \
      --parse-search \
      --cache-file /dev/null)
    
    if [[ -n "$selected" ]]; then
      # Extract the original keybind to find the command
      local selected_key="''${selected%%:*}"
      selected_key="''${selected_key// }"  # Remove trailing spaces
      
      # Find the command for this keybinding
      local command=""
      while IFS='|' read -r keybind desc cmd; do
        keybind="''${keybind// }"  # Remove spaces for comparison
        if [[ "$keybind" == "$selected_key" ]]; then
          command="$cmd"
          break
        fi
      done < "$TEMP_FILE"
      
      if [[ -n "$command" ]]; then
        echo "Executing: $command"
        notify-send "Hyprland Keybinds" "Executing: $command" -t 2000
        
        # Execute the command via hyprctl
        if [[ "$command" =~ ^exec,[[:space:]]*(.+)$ ]]; then
          # Extract executable from exec command
          local exec_cmd="''${BASH_REMATCH[1]}"
          eval "$exec_cmd" &
        elif [[ "$command" =~ ^submap,[[:space:]]*(.+)$ ]]; then
          # Handle submap commands
          local submap_name="''${BASH_REMATCH[1]}"
          hyprctl dispatch submap "$submap_name"
        else
          # Handle other hyprctl dispatchers
          hyprctl dispatch $command
        fi
      else
        notify-send "Hyprland Keybinds" "Could not find command for: $selected_key" -t 3000
      fi
    fi
  }
  
  # Main execution
  main() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
      echo "Error: Hyprland config file not found at $CONFIG_FILE"
      notify-send "Hyprland Keybinds" "Config file not found: $CONFIG_FILE" -t 3000
      exit 1
    fi
    
    echo "Parsing Hyprland keybindings from $CONFIG_FILE..."
    extract_keybinds "$CONFIG_FILE"
    
    # Show the menu
    show_keybind_menu
    
    # Cleanup
    rm -f "$TEMP_FILE"
  }
  
  main "$@"
''

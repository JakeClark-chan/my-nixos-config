#!/usr/bin/env bash

# Wallpaper changer script with circle animation
WALLPAPER_DIR="$HOME/nixos-config/backgrounds"
CURRENT_WALLPAPER_FILE="$HOME/.current_wallpaper"
ANIMATION_DURATION=300

# Function to show circle animation
show_circle_animation() {
    # Get screen dimensions
    SCREEN_WIDTH=$(hyprctl monitors -j | jq '.[0].width')
    SCREEN_HEIGHT=$(hyprctl monitors -j | jq '.[0].height')
    
    # Calculate center position
    CENTER_X=$((SCREEN_WIDTH / 2))
    CENTER_Y=$((SCREEN_HEIGHT / 2))
    
    # Create a temporary overlay window with circle animation
    echo "
    window {
        background-color: rgba(67, 85, 221, 0.8);
        border-radius: 50%;
        animation: circle-expand ${ANIMATION_DURATION}ms ease-out;
    }
    
    @keyframes circle-expand {
        from {
            width: 0px;
            height: 0px;
            left: ${CENTER_X}px;
            top: ${CENTER_Y}px;
        }
        to {
            width: 100px;
            height: 100px;
            left: $((CENTER_X - 50))px;
            top: $((CENTER_Y - 50))px;
        }
    }
    " > /tmp/circle_animation.css
    
    # Show notification with animation
    notify-send -t 1000 "🔄 Changing Wallpaper" "Switching to next background..." --icon=preferences-desktop-wallpaper
}

# Function to get next wallpaper
get_next_wallpaper() {
    local wallpapers=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.webp" \) | sort))
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        notify-send "❌ Error" "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi
    
    local current_wallpaper=""
    if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
        current_wallpaper=$(cat "$CURRENT_WALLPAPER_FILE")
    fi
    
    local next_index=0
    for i in "${!wallpapers[@]}"; do
        if [ "${wallpapers[$i]}" = "$current_wallpaper" ]; then
            next_index=$(( (i + 1) % ${#wallpapers[@]} ))
            break
        fi
    done
    
    echo "${wallpapers[$next_index]}"
}

# Function to set wallpaper
set_wallpaper() {
    local wallpaper_path="$1"
    
    # Set wallpaper using hyprpaper or swww (depending on what you use)
    if command -v swww >/dev/null 2>&1; then
        swww img "$wallpaper_path" --transition-type circle --transition-duration 1
    elif command -v hyprpaper >/dev/null 2>&1; then
        # Kill existing hyprpaper
        pkill hyprpaper 2>/dev/null
        
        # Set new wallpaper
        echo "preload = $wallpaper_path" > /tmp/hyprpaper.conf
        echo "wallpaper = ,$wallpaper_path" >> /tmp/hyprpaper.conf
        hyprpaper -c /tmp/hyprpaper.conf &
    else
        # Fallback to swaybg
        pkill swaybg 2>/dev/null
        swaybg -i "$wallpaper_path" &
    fi
    
    # Save current wallpaper
    echo "$wallpaper_path" > "$CURRENT_WALLPAPER_FILE"
    
    # Show success notification
    local wallpaper_name=$(basename "$wallpaper_path")
    notify-send -t 2000 "✅ Wallpaper Changed" "Now using: $wallpaper_name" --icon=preferences-desktop-wallpaper
}

# Main execution
main() {
    # Show animation
    show_circle_animation
    
    # Get next wallpaper
    local next_wallpaper=$(get_next_wallpaper)
    
    if [ -n "$next_wallpaper" ]; then
        # Small delay for animation effect
        sleep 0.3
        set_wallpaper "$next_wallpaper"
    else
        notify-send "❌ Error" "Could not determine next wallpaper"
        exit 1
    fi
}

# Run the script
main "$@"
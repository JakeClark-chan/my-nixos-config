#!/bin/bash
# Lock screen script using hyprlock only

# Function to show confirmation (optional)
show_menu() {
    choice=$(echo -e "Lock Screen
Cancel" | 
        wofi --dmenu 
             --prompt "Lock Screen:" 
             --width 250 
             --height 100 
             --cache-file /dev/null)
    
    case "$choice" in
        "Lock Screen")
            hyprlock
            ;;
        "Cancel"|"")
            exit 0
            ;;
    esac
}

# If argument provided, use directly
case "$1" in
    "hyprlock"|"")
        hyprlock
        ;;
    "menu")
        show_menu
        ;;
    *)
        # Default to hyprlock
        hyprlock
        ;;
esac

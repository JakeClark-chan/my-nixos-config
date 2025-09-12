{ pkgs, ... }:

pkgs.writeShellScriptBin "hdmi-control" ''
  #!/usr/bin/env bash
  
  # HDMI Control Script for Hyprland - Advanced Display Management
  # Usage: hdmi-control [mirror|extend|disable|status|help] [workspace_number]
  
  HDMI_PRIMARY="HDMI-A-1"
  HDMI_SECONDARY="HDMI-A-2"
  
  # Function to check if HDMI is connected
  check_hdmi_connected() {
    local hdmi_port="$1"
    if [ -f "/sys/class/drm/card1-$hdmi_port/status" ]; then
      cat "/sys/class/drm/card1-$hdmi_port/status" | grep -q "connected"
    else
      return 1
    fi
  }
  
  # Function to get active HDMI port
  get_active_hdmi() {
    if check_hdmi_connected "$HDMI_PRIMARY"; then
      echo "$HDMI_PRIMARY"
      return 0
    elif check_hdmi_connected "$HDMI_SECONDARY"; then
      echo "$HDMI_SECONDARY"
      return 0
    else
      return 1
    fi
  }
  
  # Function to enable HDMI mirroring
  enable_mirror() {
    echo "Enabling HDMI mirror mode..."
    
    local active_hdmi
    if active_hdmi=$(get_active_hdmi); then
      echo "HDMI detected on $active_hdmi, configuring mirror mode at 1920x1080@60Hz..."
      hyprctl keyword monitor "$active_hdmi,1920x1080@60,0x0,1,mirror,eDP-1"
      
      # Enable both if both are connected
      if check_hdmi_connected "$HDMI_PRIMARY" && check_hdmi_connected "$HDMI_SECONDARY"; then
        echo "Both HDMI ports detected, enabling dual mirroring..."
        hyprctl keyword monitor "$HDMI_PRIMARY,1920x1080@60,0x0,1,mirror,eDP-1"
        hyprctl keyword monitor "$HDMI_SECONDARY,1920x1080@60,0x0,1,mirror,eDP-1"
      fi
      
      notify-send "Display Manager" "Mirror mode enabled - laptop screen duplicated to HDMI" -i display
      echo "HDMI mirror mode enabled successfully"
    else
      echo "No HDMI display detected. Please connect an HDMI cable."
      notify-send "Display Manager" "No HDMI display detected" -i dialog-error
      exit 1
    fi
  }
  
  # Function to enable HDMI extended mode with workspace binding
  enable_extend() {
    local workspace="''${1:-5}"  # Default to workspace 5 if not specified
    echo "Enabling HDMI extended mode with workspace $workspace..."
    
    local active_hdmi
    if active_hdmi=$(get_active_hdmi); then
      echo "HDMI detected on $active_hdmi, configuring extended mode at preferred@60Hz..."
      
      # Enable HDMI with preferred resolution at 60Hz, positioned to the right
      hyprctl keyword monitor "$active_hdmi,preferred@60,1920x0,1"
      
      # Enable secondary HDMI as fallback
      if [ "$active_hdmi" = "$HDMI_PRIMARY" ] && check_hdmi_connected "$HDMI_SECONDARY"; then
        hyprctl keyword monitor "$HDMI_SECONDARY,preferred@60,3840x0,1"
      elif [ "$active_hdmi" = "$HDMI_SECONDARY" ] && check_hdmi_connected "$HDMI_PRIMARY"; then
        hyprctl keyword monitor "$HDMI_PRIMARY,preferred@60,3840x0,1"
      fi
      
      # Bind workspace to HDMI
      sleep 0.5  # Give time for monitor to initialize
      hyprctl keyword workspace "$workspace,monitor:$active_hdmi,default:true"
      
      # Switch to the workspace
      hyprctl dispatch workspace "$workspace"
      
      notify-send "Display Manager" "Extended mode enabled - Workspace $workspace on HDMI display" -i display
      echo "HDMI extended mode enabled with workspace $workspace"
    else
      echo "No HDMI display detected. Please connect an HDMI cable."
      notify-send "Display Manager" "No HDMI display detected" -i dialog-error
      exit 1
    fi
  }
  
  # Function to disable HDMI output
  disable_hdmi() {
    echo "Disabling HDMI displays..."
    
    # Disable both HDMI ports
    hyprctl keyword monitor "$HDMI_PRIMARY,disable"
    hyprctl keyword monitor "$HDMI_SECONDARY,disable"
    
    notify-send "Display Manager" "HDMI displays disabled - using laptop screen only" -i display
    echo "HDMI displays disabled successfully"
  }
  
  # Function to show display status
  show_status() {
    echo "=== Display Management Status ==="
    echo "Available HDMI ports:"
    
    if check_hdmi_connected "$HDMI_PRIMARY"; then
      echo "  ✓ HDMI-A-1: Connected"
    else
      echo "  ✗ HDMI-A-1: Not connected"
    fi
    
    if check_hdmi_connected "$HDMI_SECONDARY"; then
      echo "  ✓ HDMI-A-2: Connected"
    else
      echo "  ✗ HDMI-A-2: Not connected"
    fi
    
    echo ""
    echo "Active monitors:"
    hyprctl monitors | grep -E "Monitor|description|active workspace|mirrorOf" | sed 's/^/  /'
    
    echo ""
    echo "Display Submap Controls:"
    echo "  Win + P                 - Enter display management submap"
    echo "  \` (backtick)           - Enable mirror mode"
    echo "  1-0                    - Bind workspace to HDMI (extended mode)"
    echo "  Esc                    - Exit submap"
    echo "  Win + Shift + P        - Disable HDMI displays"
  }
  
  # Main script logic
  case "''${1:-help}" in
    mirror)
      enable_mirror
      ;;
    extend)
      enable_extend "''${2:-5}"
      ;;
    disable|off)
      disable_hdmi
      ;;
    status|check)
      show_status
      ;;
    help|--help|-h)
      echo "HDMI Control Script for Hyprland - Advanced Display Management"
      echo ""
      echo "Usage: hdmi-control [command] [workspace]"
      echo ""
      echo "Commands:"
      echo "  mirror             - Enable HDMI mirror mode (1920x1080@60Hz)"
      echo "  extend [workspace] - Enable HDMI extended mode with workspace binding"
      echo "  disable, off       - Disable HDMI displays"
      echo "  status, check      - Show current display status"
      echo "  help               - Show this help message"
      echo ""
      echo "Submap Controls (Win + P):"
      echo "  \\\` (backtick)       - Mirror mode"
      echo "  1-0                - Extended mode with workspace 1-10"
      echo "  Esc                - Exit submap"
      echo ""
      echo "Quick Controls:"
      echo "  Win + Shift + P    - Disable HDMI displays"
      echo ""
      echo "Examples:"
      echo "  hdmi-control mirror              # Enable mirror mode"
      echo "  hdmi-control extend 5            # Extended mode with workspace 5"
      echo "  hdmi-control extend              # Extended mode with workspace 5 (default)"
      ;;
    *)
      echo "Unknown command: $1"
      echo "Use 'hdmi-control help' for usage information"
      exit 1
      ;;
  esac
''

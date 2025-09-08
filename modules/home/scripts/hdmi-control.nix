{ pkgs, ... }:

pkgs.writeShellScriptBin "hdmi-control" ''
  #!/usr/bin/env bash
  
  # HDMI Control Script for Hyprland
  # Usage: hdmi-control [enable|disable|toggle|status]
  
  HDMI_PRIMARY="HDMI-A-1"
  HDMI_SECONDARY="HDMI-A-2"
  WORKSPACE_HDMI=5
  
  # Function to check if HDMI is connected
  check_hdmi_connected() {
    local hdmi_port="$1"
    if [ -f "/sys/class/drm/card1-$hdmi_port/status" ]; then
      cat "/sys/class/drm/card1-$hdmi_port/status" | grep -q "connected"
    else
      return 1
    fi
  }
  
  # Function to enable HDMI output
  enable_hdmi() {
    echo "Enabling HDMI mirroring..."
    
    # Check which HDMI port is connected
    if check_hdmi_connected "$HDMI_PRIMARY"; then
      echo "HDMI-A-1 detected, configuring mirror mode at 1920x1080@60Hz..."
      hyprctl keyword monitor "$HDMI_PRIMARY,1920x1080@60,0x0,1,mirror,eDP-1"
      ACTIVE_HDMI="$HDMI_PRIMARY"
    elif check_hdmi_connected "$HDMI_SECONDARY"; then
      echo "HDMI-A-2 detected, configuring mirror mode at 1920x1080@60Hz..."
      hyprctl keyword monitor "$HDMI_SECONDARY,1920x1080@60,0x0,1,mirror,eDP-1"
      ACTIVE_HDMI="$HDMI_SECONDARY"
    else
      echo "No HDMI display detected. Please connect an HDMI cable."
      exit 1
    fi
    
    # Check if both HDMI ports are connected and enable both for mirroring
    if check_hdmi_connected "$HDMI_PRIMARY" && check_hdmi_connected "$HDMI_SECONDARY"; then
      echo "Both HDMI ports detected, enabling dual mirroring..."
      hyprctl keyword monitor "$HDMI_PRIMARY,1920x1080@60,0x0,1,mirror,eDP-1"
      hyprctl keyword monitor "$HDMI_SECONDARY,1920x1080@60,0x0,1,mirror,eDP-1"
      ACTIVE_HDMI="$HDMI_PRIMARY and $HDMI_SECONDARY"
    fi
    
    # Wait a moment for the monitor to be recognized
    sleep 1
    
    # Send notification
    notify-send "HDMI Mirroring" "HDMI display mirroring enabled - laptop screen duplicated to HDMI" -i display
    
    echo "HDMI mirroring enabled on $ACTIVE_HDMI - laptop screen duplicated to external display(s)"
  }
  
  # Function to disable HDMI output
  disable_hdmi() {
    echo "Disabling HDMI mirroring..."
    
    # Disable both HDMI ports
    hyprctl keyword monitor "$HDMI_PRIMARY,disable"
    hyprctl keyword monitor "$HDMI_SECONDARY,disable"
    
    # Send notification
    notify-send "HDMI Mirroring" "HDMI display mirroring disabled - using laptop screen only" -i display
    
    echo "HDMI mirroring disabled - using laptop screen only"
  }
  
  # Function to toggle HDMI output
  toggle_hdmi() {
    # Check if any HDMI is currently active
    if hyprctl monitors | grep -q "HDMI"; then
      disable_hdmi
    else
      enable_hdmi
    fi
  }
  
  # Function to show HDMI status
  show_status() {
    echo "=== HDMI Mirroring Status ==="
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
    echo "Mirroring Mode: All displays show the same content (laptop screen duplicated)"
    echo "HDMI Resolution: 1920x1080@60Hz when enabled"
  }
  
  # Main script logic
  case "''${1:-help}" in
    enable|on)
      enable_hdmi
      ;;
    disable|off)
      disable_hdmi
      ;;
    toggle)
      toggle_hdmi
      ;;
    status|check)
      show_status
      ;;
    help|--help|-h)
      echo "HDMI Control Script for Hyprland - Mirroring Mode"
      echo ""
      echo "Usage: hdmi-control [command]"
      echo ""
      echo "Commands:"
      echo "  enable, on     - Enable HDMI mirroring (duplicate laptop screen to HDMI)"
      echo "  disable, off   - Disable HDMI mirroring (laptop screen only)"
      echo "  toggle         - Toggle HDMI mirroring on/off"
      echo "  status, check  - Show current HDMI and monitor status"
      echo "  help           - Show this help message"
      echo ""
      echo "Mirror Mode: All displays show the same content"
      echo "HDMI Resolution: 1920x1080@60Hz"
      echo "Laptop Resolution: 1920x1080@144Hz"
      ;;
    *)
      echo "Unknown command: $1"
      echo "Use 'hdmi-control help' for usage information"
      exit 1
      ;;
  esac
''

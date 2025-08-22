{ config, pkgs, ... }:

let
  # Wrapper that runs the repo script with Python
  lxcGui = pkgs.writeShellScriptBin "lxc-gui" ''
    exec ${pkgs.python313Full}/bin/python ${./scripts/lxc_gui_standalone.py} "$@"
  '';

  # Volume control script with notifications
  volumeScript = pkgs.writeShellScriptBin "volume-control" ''
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
  '';

  # Brightness control script with notifications
  brightnessScript = pkgs.writeShellScriptBin "brightness-control" ''
    #!/bin/bash
    case "$1" in
      "up")
        ${pkgs.brightnessctl}/bin/brightnessctl set 5%+
        ;;
      "down")
        ${pkgs.brightnessctl}/bin/brightnessctl set 5%-
        ;;
    esac
    
    # Get current brightness percentage
    BRIGHTNESS=$(${pkgs.brightnessctl}/bin/brightnessctl get)
    MAX_BRIGHTNESS=$(${pkgs.brightnessctl}/bin/brightnessctl max)
    PERCENTAGE=$((BRIGHTNESS * 100 / MAX_BRIGHTNESS))
    
    ${pkgs.libnotify}/bin/notify-send -t 2000 -h string:x-canonical-private-synchronous:brightness "Brightness" "$PERCENTAGE%" -i display-brightness
  '';

  # Beautiful lock screen script
  lockScreenScript = pkgs.writeShellScriptBin "lock-screen" ''
    #!/bin/bash
    # Beautiful lock screen script with options

    # Function to show menu
    show_menu() {
        choice=$(echo -e "Hyprlock (Recommended)\nSwaylock Effects\nCancel" | \
            ${pkgs.wofi}/bin/wofi --dmenu \
                 --prompt "Choose Lock Screen:" \
                 --width 300 \
                 --height 150 \
                 --cache-file /dev/null)
        
        case "$choice" in
            "Hyprlock (Recommended)")
                ${pkgs.hyprlock}/bin/hyprlock
                ;;
            "Swaylock Effects")
                ${pkgs.swaylock-effects}/bin/swaylock --config /home/jc/.config/swaylock/config
                ;;
            "Cancel"|"")
                exit 0
                ;;
        esac
    }

    # If argument provided, use directly
    case "$1" in
        "hyprlock")
            ${pkgs.hyprlock}/bin/hyprlock
            ;;
        "swaylock")
            ${pkgs.swaylock-effects}/bin/swaylock --config /home/jc/.config/swaylock/config
            ;;
        "menu")
            show_menu
            ;;
        *)
            # Default to hyprlock (recommended for Hyprland)
            ${pkgs.hyprlock}/bin/hyprlock
            ;;
    esac
  '';

  # Graceful shutdown script
  shutdownScript = pkgs.writeShellScriptBin "graceful-shutdown" ''
    #!/bin/bash
    
    ACTION="$1"  # "shutdown" or "reboot"
    
    if [ -z "$ACTION" ]; then
        echo "Usage: graceful-shutdown [shutdown|reboot]"
        exit 1
    fi
    
    # Function to get running applications with windows
    get_running_apps() {
        ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.workspace.id != -99) | .class' | sort -u
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
        
        # Close all Hyprland clients gracefully first
        ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.workspace.id != -99) | .address' | while read addr; do
            ${pkgs.hyprland}/bin/hyprctl dispatch closewindow address:$addr
        done
        
        sleep 2
        
        # Force kill any remaining processes if needed
        pkill -f "firefox|code|vlc|kitty" 2>/dev/null || true
    }
    
    # Function to gracefully close applications
    graceful_close_apps() {
        echo "Attempting graceful shutdown of applications..."
        
        # Send close signals to all windows
        ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.workspace.id != -99) | .address' | while read addr; do
            ${pkgs.hyprland}/bin/hyprctl dispatch closewindow address:$addr
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
  '';
in
{
  home.username = "jc";
  home.homeDirectory = "/home/jc";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    vlc
    gthumb
    onlyoffice-desktopeditors # for office work
    jdk
    
    #distrobox # for sandboxing applications - open when docker or podman is installed
    python313Packages.uv # for virtual environments
    flameshot # for screenshot
    mission-center
    nvtopPackages.nvidia

    ani-cli # for anime streaming
    python313Packages.yt-dlp
    lxcGui
    volumeScript
    brightnessScript
    lockScreenScript
    shutdownScript

    gemini-cli 
  ];

  # Desktop launcher for the script (appears in your app menu)
  xdg.desktopEntries.lxc-gui = {
    name = "LXC GUI Standalone";
    comment = "Manage LXD containers";
    exec = "lxc-gui";
    terminal = false;
    categories = [ "Utility" "System" ];
  };

  # Git
  programs.git = {
    enable = true;
    userName = "JakeClark";
    userEmail = "jakeclark38b@gmail.com";
  };

  # Firefox configuration for proper font rendering
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        # Force DPI to 96 to prevent auto-scaling
        "layout.css.dpi" = 96;
        # Disable automatic font size scaling
        "layout.css.devPixelsPerPx" = "0.9";
        # Set default font sizes (these should match your expected 14px)
        "font.default.x-western" = "sans-serif";
        "font.size.variable.x-western" = 12;
        "font.size.fixed.x-western" = 12;
        "font.minimum-size.x-western" = 9;
        # Disable font auto-scaling
        "browser.display.auto_quality_min_font_size" = 0;
        # Enable Wayland for better integration
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # Default zoom is 120%
        "layout.css.zoom" = "1.33";
      };
    };
  };

  # npm configuration
  home.file.".npmrc".text = ''
    prefix=~/.npm-global
    cache=~/.npm-cache
    init-author-name=JakeClark
    init-author-email=jakeclark38b@gmail.com
    init-license=MIT
  '';

  # Add npm global bin to PATH
  home.sessionVariables = {
    PATH = "$HOME/.npm-global/bin:$PATH";
    # Cursor theme configuration
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # Configuration
  xdg.configFile."starship.toml".source = ./.config/starship.toml;
  
  # Hyprland configuration
  xdg.configFile."hypr/hyprland.conf".source = ./.config/hypr/hyprland.conf;
  
  # Hyprlock configuration (using Home Manager)
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = false;
        immediate_render = true;
      };
      
      background = [
        {
          monitor = "";
          path = "/home/jc/nixos-config/shiho.jpg";
          blur_passes = 3;
          blur_size = 8;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];
      
      label = [
        # Date
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%A, %B %d, %Y")"'';
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 22;
          font_family = "Cascadia Code NF2";
          position = "0, 300";
          halign = "center";
          valign = "center";
        }
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 95;
          font_family = "Cascadia Code NF2";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        # Instruction
        {
          monitor = "";
          text = "Click or press Enter to unlock";
          color = "rgba(242, 243, 244, 0.50)";
          font_size = 16;
          font_family = "Cascadia Code NF2";
          position = "0, -250";
          halign = "center";
          valign = "center";
        }
      ];
      
      input-field = [
        {
          monitor = "";
          size = "300, 60";
          outline_thickness = 4;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          dots_rounding = -1;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(0, 0, 0, 0.2)";
          font_color = "rgba(200, 200, 200, 1.0)";
          fade_on_empty = false;
          fade_timeout = 1000;
          placeholder_text = "<i><span foreground=\"##cdd6f4\">🔒 Enter Password</span></i>";
          hide_input = false;
          rounding = 15;
          check_color = "rgba(204, 136, 34, 0)";
          fail_color = "rgba(204, 34, 34, 0)";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = -1;
          numlock_color = -1;
          bothlock_color = -1;
          invert_numlock = false;
          swap_font_color = false;
          position = "0, -170";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # Swaylock configuration
  xdg.configFile."swaylock/config".source = ./.config/swaylock/config;

  # Waybar configuration
  xdg.configFile."waybar/config.jsonc".source = ./.config/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./.config/waybar/style.css;

  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    font = {
      name = "Cascadia Code NF2";
      size = 14;
    };
    settings = {
      # Window settings
      window_padding_width = 10;
      window_margin_width = 0;
      
      # Disable close confirmation
      confirm_os_window_close = 0;
      
      # Color scheme
      background_opacity = "0.95";
      
      # Performance
      sync_to_monitor = "yes";
    };
  };

  # GTK theme configuration
  gtk = {
    enable = true;
    font = {
      name = "SDK SC Web";
      size = 14;
    };
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  # Qt theme configuration
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  # Desktop entries for graceful shutdown/reboot
  xdg.desktopEntries = {
    graceful-shutdown = {
      name = "Graceful Shutdown";
      comment = "Gracefully shutdown the system";
      exec = "graceful-shutdown shutdown";
      terminal = false;
      icon = "system-shutdown";
      categories = [ "System" ];
    };
    
    graceful-reboot = {
      name = "Graceful Reboot";
      comment = "Gracefully reboot the system";
      exec = "graceful-shutdown reboot";
      terminal = false;
      icon = "system-reboot";
      categories = [ "System" ];
    };
  };

  # Systemd user services for graceful shutdown
  systemd.user.services = {
    graceful-shutdown-handler = {
      Unit = {
        Description = "Graceful shutdown handler";
        DefaultDependencies = false;
        Before = [ "shutdown.target" "reboot.target" ];
      };
      
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/true";
        ExecStop = "${shutdownScript}/bin/graceful-shutdown shutdown";
        TimeoutStopSec = 60;
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
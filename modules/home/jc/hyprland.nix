{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration
      monitor = [
        # Set laptop monitor to 1x scaling
        "eDP-1,1920x1080@144,0x0,1"
        # HDMI outputs disabled by default (configured via submap)
        "HDMI-A-1,disable"
        "HDMI-A-2,disable"
        # Fallback rule for any unspecified monitor
        ",preferred,auto,1"
      ];

      # Programs
      "$terminal" = "kitty";
      "$fileManager" = "thunar";
      "$menu" = "wofi --show drun";
      "$mainMod" = "SUPER";

      # Autostart applications
      exec-once = [
        # Wallpaper daemon
        "swww-daemon"
        
        # Status bar and notifications
        "waybar"
        "swaync"
        
        # Night light with 3100K color temperature
        "hyprsunset -t 3100"
        
        # Input method
        "fcitx5 -d"
        
        # System tray applications
        "nm-applet --indicator"
        "flameshot"
        
        # Authentication agent
        "lxqt-policykit-agent"
        
        # Clipboard manager
        "wl-paste --watch cliphist store"
      ];

      # Environment variables
      env = [
        # Cursor configuration
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        
        # Scaling environment variables - set to 1x
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        
        # Firefox-specific DPI and font scaling
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_DPI,96"
        "MOZ_SCALE_FACTOR,1"
        
        # Nvidia
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      # General configuration
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(00ff00ee) rgba(00cc44ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        # POWER SAVING OPTIMIZATIONS:
        # - Blur and shadows are disabled to reduce GPU usage and extend battery life
        # - These can be re-enabled by setting blur:enabled = true and shadow:enabled = true
        rounding = 10;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        
        shadow = {
          enabled = false; # POWER SAVING: Disable shadows to reduce GPU usage
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        
        blur = {
          enabled = false; # POWER SAVING: Disable blur effects to reduce GPU usage and save battery
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      # Animations
      animations = {
        enabled = true; # yes, please :)
        
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      # Dwindle layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Master layout
      master = {
        new_status = "master";
      };

      # Misc
      misc = {
        force_default_wallpaper = 0; # Disable the anime mascot wallpapers to use custom wallpaper
        disable_hyprland_logo = true; # Disable the random hyprland logo / anime girl background
        vfr = true; # POWER SAVING: Variable Frame Rate - reduces frames when nothing is happening on screen
        enable_swallow = false; # Disable window swallowing (slight power save)
      };

      # Input configuration
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        follow_mouse = 2; # Disable focus follows mouse but keep scroll activation
        sensitivity = 0;
        
        touchpad = {
          natural_scroll = true;
        };
      };

      # Per-device configuration
      device = [
        {
          name = "sigmachip-usb-mouse";
          sensitivity = -0.8;
        }
      ];

      # Keybindings
      bind = [
        # Application launchers
        "$mainMod, D, exec, $menu"
        "$mainMod, Return, exec, $terminal"
        "$mainMod, E, exec, $fileManager"
        
        # Window management
        "$mainMod SHIFT, Q, killactive,"
        "$mainMod, space, togglefloating,"
        "$mainMod, F, fullscreen, 0"
        
        # Layout management
        "$mainMod, T, exec, hyprctl keyword general:layout \"$(hyprctl getoption general:layout | grep -q 'dwindle' && echo 'master' || echo 'dwindle')\"" # Toggle between dwindle and master layouts
        "$mainMod, H, togglesplit," # dwindle: toggle split orientation
        "$mainMod SHIFT, H, layoutmsg, orientationcenter" # master: center master area
        
        # Focus movement
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        
        # Window movement
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, r"
        
        # Resize mode
        "$mainMod, R, submap, resize"
        
        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        
        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        
        # Utility keybindings
        "$mainMod, V, exec, cliphist list | wofi --dmenu --pre-display-cmd \"echo '%s' | cut -f 2\" | cliphist decode | wl-copy" # Clipboard history
        "$mainMod SHIFT, E, exit," # Exit Hyprland
        "$mainMod, N, exec, pkill hyprsunset || hyprsunset -t 3100"
        "$mainMod, M, exec, pkill waybar || waybar"
        
        # System control
        "CTRL ALT, Delete, exec, graceful-shutdown shutdown"
        "CTRL ALT SHIFT, Delete, exec, graceful-shutdown reboot"
        "$mainMod, L, exec, lock-screen"
        "$mainMod SHIFT, L, exec, lock-screen menu"
        
        # Home Manager and help
        "$mainMod SHIFT, H, exec, apply-home-manager"
        "$mainMod SHIFT, slash, exec, hyprland-keybinds"
        
        # Display management
        "$mainMod, P, submap, display"
        "$mainMod SHIFT, P, exec, hyprctl keyword monitor \"HDMI-A-1,disable\" && hyprctl keyword monitor \"HDMI-A-2,disable\" && notify-send \"Display\" \"HDMI monitors disabled\""
        
        # Wallpaper management
        "$mainMod, W, exec, change-wallpaper"
        "$mainMod SHIFT, W, exec, change-wallpaper random"
        
        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        
        # Workspace navigation
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod CTRL, left, workspace, e-1"
        "$mainMod CTRL, right, workspace, e+1"
        
        # Screenshots
        ", Print, exec, flameshot gui"
        "$mainMod, Print, exec, flameshot screen"
      ];
      
      # Bind keys that repeat
      binde = [
        # Multimedia keys for volume
        ",XF86AudioRaiseVolume, exec, volume-control up"
        ",XF86AudioLowerVolume, exec, volume-control down"
        ",XF86AudioMute, exec, volume-control mute"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        
        # Brightness controls
        ",XF86MonBrightnessUp, exec, brightness-control up"
        ",XF86MonBrightnessDown, exec, brightness-control down"
      ];

      # Media keys that don't repeat
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Window rules
      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };

    # Additional submaps configuration
    extraConfig = ''
      # Resize submap configuration
      submap = resize
      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      binde = , up, resizeactive, 0 -10
      binde = , down, resizeactive, 0 10
      bind = , escape, submap, reset
      submap = reset

      # Display management submap
      submap = display
      
      # Mirror mode
      bind = , grave, exec, hyprctl keyword monitor "HDMI-A-1,1920x1080@60,0x0,1,mirror,eDP-1" && hyprctl keyword monitor "HDMI-A-2,1920x1080@60,0x0,1,mirror,eDP-1" && notify-send "Display" "Mirror mode enabled - laptop screen duplicated to HDMI"
      
      # Extended mode - workspace bindings
      bind = , 1, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "1,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 1 bound to HDMI display"
      bind = , 2, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "2,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 2 bound to HDMI display"
      bind = , 3, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "3,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 3 bound to HDMI display"
      bind = , 4, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "4,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 4 bound to HDMI display"
      bind = , 5, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "5,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 5 bound to HDMI display"
      bind = , 6, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "6,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 6 bound to HDMI display"
      bind = , 7, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "7,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 7 bound to HDMI display"
      bind = , 8, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "8,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 8 bound to HDMI display"
      bind = , 9, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "9,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 9 bound to HDMI display"
      bind = , 0, exec, hyprctl keyword monitor "HDMI-A-1,preferred@60,1920x0,1" && hyprctl keyword monitor "HDMI-A-2,preferred@60,1920x0,1" && hyprctl keyword workspace "10,monitor:HDMI-A-1,default:true" && notify-send "Display" "Workspace 10 bound to HDMI display"
      
      bind = , escape, submap, reset
      submap = reset
    '';
  };
}
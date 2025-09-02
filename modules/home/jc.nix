{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:
let
  lxcGui = pkgs.callPackage ./scripts/lxc-gui.nix {};
  shutdownScript = pkgs.callPackage ./scripts/graceful-shutdown.nix {};
  volumeScript = pkgs.callPackage ./scripts/volume-control.nix {};
  brightnessScript = pkgs.callPackage ./scripts/brightness-control.nix {};
  lockScreenScript = pkgs.callPackage ./scripts/lock-screen.nix {};
  homeManagerScript = import ./scripts/apply-home-manager.nix { inherit pkgs config; };
in
{
  home.username = systemSettings.username;
  home.homeDirectory = systemSettings.homeDirectory;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    vlc
    gthumb
    onlyoffice-desktopeditors # for office work
    
    #distrobox # for sandboxing applications - open when docker or podman is installed
    python313Packages.uv # for virtual environments
    flameshot # for screenshot
    grim
    mission-center
    nvtopPackages.nvidia
    

    ani-cli # for anime streaming
    python313Packages.yt-dlp
    lxcGui
    volumeScript
    brightnessScript
    lockScreenScript
    shutdownScript
    homeManagerScript

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
    userName = homeSettings.git.name;
    userEmail = homeSettings.git.email;
  };

  # npm configuration
  home.file.".npmrc".text = ''
    prefix=~/.npm-global
    cache=~/.npm-cache
    init-author-name=${homeSettings.npm.authorName}
    init-author-email=${homeSettings.npm.authorEmail}
    init-license=${homeSettings.npm.license}
  '';

  # Add npm global bin to PATH
  home.sessionVariables = {
    PATH = "$HOME/.npm-global/bin:$PATH";
    # Cursor theme configuration
    XCURSOR_THEME = desktopSettings.cursorTheme;
    XCURSOR_SIZE = toString desktopSettings.cursorSize;
  };

  # Configuration
  xdg.configFile."starship.toml".source = ./.config/starship.toml;
  
  # Hyprland configuration
  xdg.configFile."hypr/hyprland.conf".text = builtins.replaceStrings [ "@backgroundPath@" ] [ desktopSettings.hyprland.backgroundPath ] (builtins.readFile ./.config/hypr/hyprland.conf);
  
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
          path = desktopSettings.hyprland.backgroundPath;
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

  # Swaync notification daemon
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      "layer" = "top";
      "control-center-layer" = "overlay";
      "layer-shell" = true;
      "cssPriority" = "user";
      "control-center-width" = 500;
      "control-center-height" = 600;
      "notification-window-width" = 400;
      "keyboard-shortcuts" = true;
      "image-visibility" = "when-available";
      "transition-time" = 200;
      "hide-on-action" = true;
      "hide-on-empty" = false;
      "widgets" = [ "title" "dnd" "notifications" "mpris" ];
      "widget-config" = {
        "title" = {
          "text" = " Notifications";
          "clear-all-button" = true;
          "button-text" = "Clear All";
        };
        "dnd" = {
          "text" = "Do Not Disturb";
        };
        "notifications" = {
          "label" = "Notifications";
          "actions" = ["default" "open"];
        };
        "mpris" = {
          "label" = "Media Player";
          "actions" = ["play-pause" "next" "previous"];
        };
      };
    };
  };

  # Removed swaylock: hyprlock is the sole lock screen now

  # Flameshot configuration
  xdg.configFile."flameshot/flameshot.ini".source = ./.config/flameshot/flameshot.ini;

  # Waybar configuration
  xdg.configFile."waybar/config.jsonc".source = ./.config/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./.config/waybar/style.css;

  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    font = {
      name = builtins.head desktopSettings.fontProfiles.monospace;
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
      name = builtins.head desktopSettings.fontProfiles.sansSerif;
      size = 14;
    };
    theme = {
      name = desktopSettings.theme;
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name = desktopSettings.cursorTheme;
      package = pkgs.adwaita-icon-theme;
      size = desktopSettings.cursorSize;
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

  # Systemd user services configuration
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
        # ExecStop = "${shutdownScript}/bin/graceful-shutdown shutdown";
        TimeoutStopSec = 60;
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  
}

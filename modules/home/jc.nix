{ config, pkgs, inputs, ... }:

let
  # Import script modules
  lxcGui = import ./scripts/lxc-gui.nix { inherit pkgs; };
  volumeScript = import ./scripts/volume-control.nix { inherit pkgs; };
  brightnessScript = import ./scripts/brightness-control.nix { inherit pkgs; };
  lockScreenScript = import ./scripts/lock-screen.nix { inherit pkgs; };
  shutdownScript = import ./scripts/graceful-shutdown.nix { inherit pkgs; };
  homeManagerScript = import ./scripts/apply-home-manager.nix { inherit pkgs config; };
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
    userName = "JakeClark";
    userEmail = "jakeclark38b@gmail.com";
  };

  # Zen Browser configuration (Firefox-based browser)
  programs.zen-browser = {
    enable = true;
    # package = inputs.zen-browser.packages.${pkgs.system}.default; # Removed: provided by module
    
    # Native messaging hosts for extensions
    # nativeMessagingHosts = [ pkgs.firefoxpwa ];

    # Browser policies (recommended settings from upstream)
    policies = {
      # Privacy and security settings
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      # Preferences (inherited from Firefox config + Zen-specific)
      Preferences = let
        mkLockedAttrs = builtins.mapAttrs (_: value: {
          Value = value;
          Status = "locked";
        });
      in mkLockedAttrs {
        # Font rendering (inherited from Firefox config)
        "layout.css.devPixelsPerPx" = "1.0";
        "font.default.x-western" = "sans-serif";
        "font.size.variable.x-western" = 12;
        "font.size.fixed.x-western" = 12;
        "font.minimum-size.x-western" = 9;
        "layout.css.zoom" = "1.2";
        
        # Wayland integration (inherited from Firefox config)
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        
        # Browser behavior
        "browser.tabs.warnOnClose" = false;
        "browser.startup.page" = 3; # Restore previous session
        "browser.sessionstore.restore_on_demand" = true;
        
        # Performance optimizations
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        
        # Privacy settings
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        
        # Zen-specific preferences
        # Check: https://github.com/0xc000022070/zen-browser-flake/issues/59#issuecomment-2964607780
        # Add Zen-specific settings here when you find preferences you want to lock
      };

      # Extensions configuration (example - you can add your extensions here)
      # ExtensionSettings = let
      #   mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
      #     install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
      #     installation_mode = "force_installed";
      #   });
      # in mkExtensionSettings {
      #   # Example extensions (uncomment and modify as needed):
      #   # "uBlock0@raymondhill.net" = "ublock-origin";
      #   # "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
      # };
    };

    profiles.default = {
      # You can add additional profile-specific settings here
      
      # Containers configuration (example)
      # containers = {
      #   Personal = {
      #     color = "purple";
      #     icon = "fingerprint";
      #     id = 1;
      #   };
      #   Work = {
      #     color = "blue";
      #     icon = "briefcase";
      #     id = 2;
      #   };
      # };
      
      # Spaces configuration (Zen-specific feature)
      # spaces = {
      #   "Main" = {
      #     id = "c6de089c-410d-4206-961d-ab11f988d40a";
      #     position = 1000;
      #   };
      # };
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
        ExecStop = "${shutdownScript}/bin/graceful-shutdown shutdown";
        TimeoutStopSec = 60;
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  # Mask swaync systemd service since we start it via Hyprland exec-once
  systemd.user.services.swaync = {
    Unit = {
      Description = "Masked: swaync started via Hyprland";
    };
    Install = {
      WantedBy = pkgs.lib.mkForce [ ];
    };
  };
}
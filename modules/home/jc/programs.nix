{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:

{
  # Program configurations
  programs = {
    # Neovim configuration
    neovim = {
      enable = true;
      extraLuaConfig = builtins.readFile ../nvim/init.lua;
      extraPackages = with pkgs; [
        vimPlugins.lazy-nvim
        vimPlugins.nvim-lspconfig
        # Language Server
        pyright # Python
        nil # Nix Language
      ];
    };

    # Git configuration
    git = {
      enable = true;
      userName = homeSettings.git.name;
      userEmail = homeSettings.git.email;
    };

    # Kitty terminal configuration
    kitty = {
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

    # Hyprlock configuration (using Home Manager)
    hyprlock = {
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

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
    zsh.enable = true;
  };
}

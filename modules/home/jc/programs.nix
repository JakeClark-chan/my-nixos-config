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

    # Hyprlock removed (Hyprland-specific)
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

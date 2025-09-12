{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:

{
  # File configurations and environment setup
  
  # npm configuration
  home.file.".npmrc".text = ''
    prefix=~/.npm-global
    cache=~/.npm-cache
    init-author-name=${homeSettings.npm.authorName}
    init-author-email=${homeSettings.npm.authorEmail}
    init-license=${homeSettings.npm.license}
  '';

  # Session variables
  home.sessionVariables = {
    PATH = "$HOME/.npm-global/bin:$PATH";
    # Cursor theme configuration
    XCURSOR_THEME = desktopSettings.cursorTheme;
    XCURSOR_SIZE = toString desktopSettings.cursorSize;
  };

  # XDG configuration files
  xdg.configFile = {
    # Flameshot configuration
    "flameshot/flameshot.ini".source = ../.config/flameshot/flameshot.ini;

    # Waybar configuration
    "waybar/config.jsonc".source = ../.config/waybar/config.jsonc;
    "waybar/style.css".source = ../.config/waybar/style.css;

    # Starship configuration
    "starship.toml".source = ../.config/starship.toml;
    
    # Hyprland configuration
    "hypr/hyprland.conf".text = builtins.replaceStrings 
      [ "@backgroundPath@" ] 
      [ desktopSettings.hyprland.backgroundPath ] 
      (builtins.readFile ../.config/hypr/hyprland.conf);
  };
}

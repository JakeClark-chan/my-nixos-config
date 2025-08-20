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
        ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+
        ;;
      "down")
        ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
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
    # mission_center_unstable
    nvtopPackages.nvidia

    ani-cli # for anime streaming
    python313Packages.yt-dlp
    lxcGui
    volumeScript
    brightnessScript

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

  # Waybar configuration
  xdg.configFile."waybar/config".source = ./.config/waybar/config;
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
}
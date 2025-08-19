{ config, pkgs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable XDG desktop portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Font configuration
  fonts = {
    packages = with pkgs; [
      cascadia-code  # For Cascadia Code NF (monospace)
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "SDK_SC_Web" "Noto Serif" ];
        sansSerif = [ "SDK_SC_Web" ];
        monospace = [ "Cascadia Code NF" "Cascadia Mono NF" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Enable display manager for Hyprland with autologin
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "jc";
      };
    };
  };

  # Configure keymap (Wayland)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

    # Essential packages for Hyprland
  environment.systemPackages = with pkgs; [
    # Fonts and cursors
    noto-fonts-emoji
    adwaita-icon-theme  # For Adwaita cursor theme
    cascadia-code
    
    # System utilities
    brightnessctl       # Brightness control
    libnotify          # For notifications
    hyprsunset         # Night light for Hyprland (official hypr-ecosystem tool)
    
    # Wayland utilities
    waybar          # Status bar
    wofi            # Application launcher
    wl-clipboard    # Clipboard utilities
    grim            # Screenshot utility
    slurp           # Screen area selection
    swaynotificationcenter  # Notification daemon
    swaylock-effects        # Screen locker
    swayidle        # Idle management
    swww            # Wallpaper daemon for Wayland
    
    # File manager and utilities
    xfce.thunar        # File manager
    networkmanagerapplet  # Network manager applet
    
    # Terminal emulator
    kitty           # Terminal (you can change this)
    
    # Custom background (if you want to keep it)
    (pkgs.runCommand "custom-background" { } ''
      mkdir -p $out/share/backgrounds
      cp ${../../shiho.jpg} $out/share/backgrounds/
    '')
  ];

  # Auto-login (optional, comment out if you prefer manual login)
  # Note: With greetd, this would require additional configuration
  # services.greetd.settings.default_session.command = "${pkgs.hyprland}/bin/Hyprland";

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Set 1x scaling for all applications
    GDK_SCALE = "1";
    QT_SCALE_FACTOR = "1";
    # Font configuration
    QT_FONT_DPI = "96";
    # Input method configuration (fcitx5 already configured in locale.nix)
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
  };
}

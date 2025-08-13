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

  # Enable display manager for Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
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
    # Wayland utilities
    waybar          # Status bar
    wofi            # Application launcher
    wl-clipboard    # Clipboard utilities
    grim            # Screenshot utility
    slurp           # Screen area selection
    swaynotificationcenter  # Notification daemon
    swaylock-effects        # Screen locker
    swayidle        # Idle management
    
    # File manager and utilities
    nautilus        # File manager
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
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
}

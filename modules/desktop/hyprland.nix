{ config, pkgs, systemSettings, desktopSettings, ... }:

{
  # Import general desktop settings
  imports = [
    ./general.nix
  ];

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable display manager for Hyprland with autologin
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = systemSettings.username;
      };
    };
  };

  # Configure keymap (Wayland)
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
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
    hyprlock                # Hyprland-native screen locker
    swayidle        # Idle management
    swww            # Wallpaper daemon for Wayland
    hyprpaper       # Alternative wallpaper daemon for Hyprland
    glfw            # OpenGL framework for Wayland
    hyprsunset         # Night light for Hyprland (official hypr-ecosystem tool)
    hyprpicker         # Color picker for Hyprland (official hypr-ecosystem tool)
    # hyprshot        # Screenshot tool for Hyprland (commented out, use grim + slurp instead)
    # Terminal emulator
    kitty           # Terminal (you can change this)
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
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
  };
}

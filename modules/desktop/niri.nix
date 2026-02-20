{ config, pkgs, inputs, systemSettings, desktopSettings, ... }:

{
  # Import general desktop settings
  imports = [
    ./general.nix
  ];

  # Enable Niri (provided by niri-flake nixosModule)
  programs.niri.enable = true;

  # Enable display manager for Niri with autologin
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "niri-session";
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

  # Essential packages for Niri
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    waybar          # Status bar
    wofi            # Application launcher
    wl-clipboard    # Clipboard utilities
    grim            # Screenshot utility
    slurp           # Screen area selection
    swaynotificationcenter  # Notification daemon
    swayidle        # Idle management
    wlsunset        # Night light for Wayland
    xwayland-satellite  # XWayland support for Niri
    wl-color-picker    # Color picker for Wayland
    glfw            # OpenGL framework for Wayland

    # COSMIC desktop applications
    cosmic-term      # Terminal emulator
    cosmic-files     # File manager
    cosmic-launcher  # Application launcher

    # Wallpaper daemon (awww from Codeberg flake)
    inputs.awww.packages.${pkgs.system}.default

    # Clipboard manager
    cliphist        # Clipboard history manager

    # Terminal emulator (fallback)
    kitty           # Terminal (fallback)
  ];

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
    # Niri session
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
  };
}

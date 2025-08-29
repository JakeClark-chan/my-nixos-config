{ config, pkgs, systemSettings, desktopSettings, ... }:

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

  # Enable GVFS for file manager trash and mount functionality
  services.gvfs.enable = true;
  
  # Enable polkit for authentication (required for file operations)
  security.polkit.enable = true;
  
  # Enable Thunar with proper volume management
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };

  # Enable udisks2 for disk mounting
  services.udisks2.enable = true;

  # Polkit rules for disk mounting
  security.polkit.extraConfig = ''
    /* Allow members of the wheel group to mount/unmount filesystems without password */
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount" ||
             action.id == "org.freedesktop.udisks2.filesystem-unmount" ||
             action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
             action.id == "org.freedesktop.udisks2.encrypted-lock" ||
             action.id == "org.freedesktop.udisks2.eject-media" ||
             action.id == "org.freedesktop.udisks2.power-off-drive") &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    });
  '';

  # Font configuration
  fonts = {
    packages = desktopSettings.fontPackages;
    
    fontconfig = {
      enable = true;
      defaultFonts = desktopSettings.fontProfiles;
    };
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
    # Cursors
    adwaita-icon-theme  # For Adwaita cursor theme
    
    # System utilities
    brightnessctl       # Brightness control
    libnotify          # For notifications
    hyprsunset         # Night light for Hyprland (official hypr-ecosystem tool)
    playerctl          # Media player control

    # Around Minecraft Launcher
    xorg.libXxf86vm         # For JavaFX on XWayland
    glib               # For JavaFX GTK backend
    temurin-bin
    xwayland-satellite
    xorg.libXext
    xorg.libXrender
    

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

    # File manager and utilities
    xfce.thunar        # File manager
    xfce.thunar-volman # Volume management for Thunar
    gvfs               # Virtual file system (required for trash)
    gnome-settings-daemon  # Settings daemon for proper file operations
    lxqt.lxqt-policykit # Lightweight polkit authentication agent
    udisks2            # Disk management service
    ntfs3g             # NTFS filesystem support
    exfat              # exFAT filesystem support
    networkmanagerapplet  # Network manager applet
    
    # Archive manager
    zip
    unzip
    rar
    unrar
    p7zip
    # Frontend for thunar
    xfce.thunar-archive-plugin
    xarchiver
    # Terminal emulator
    kitty           # Terminal (you can change this)
    
    # Custom background (if you want to keep it)
    # (pkgs.runCommand "custom-background" { } ''
    #   mkdir -p $out/share/backgrounds
    #   cp ${../../shiho.jpg} $out/share/backgrounds/
    # '')
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

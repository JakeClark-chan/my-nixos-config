{ config, pkgs, systemSettings, desktopSettings, ... }:

{
  # Enable XDG desktop portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Disable GNOME's GCR SSH agent (conflicts with programs.ssh.startAgent in development.nix)
  services.gnome.gcr-ssh-agent.enable = false;

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

  # Essential packages for WM
  environment.systemPackages = with pkgs; [
    # Cursors
    adwaita-icon-theme  # For Adwaita cursor theme
    
    # System utilities
    brightnessctl       # Brightness control
    libnotify          # For notifications
    playerctl          # Media player control

    # File manager and utilities
    thunar             # File manager
    thunar-volman      # Volume management for Thunar
    gvfs               # Virtual file system (required for trash)
    gnome-settings-daemon  # Settings daemon for proper file operations
    lxqt.lxqt-policykit # Lightweight polkit authentication agent
    udisks2            # Disk management service
    ntfs3g             # NTFS filesystem support
    exfat              # exFAT filesystem support
    networkmanagerapplet  # Network manager applet
    
    # Frontend for thunar
    thunar-archive-plugin
    xarchiver
  ];
}
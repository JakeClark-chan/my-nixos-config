# Desktop environment and window manager settings

{
  # Scaling factor for displays
  scalingFactor = 1.2;
  # DPI for X11 applications
  xftDpi = 115; # 96 * 1.2

  # Font configuration
  fontProfiles = {
    serif = [ "SDK_SC_Web" "Noto Serif" ];
    sansSerif = [ "SDK_SC_Web" ];
    monospace = [ "Cascadia Code NF" "Cascadia Mono NF" ];
    emoji = [ "Noto Color Emoji" ];
  };
  fontPackages = with pkgs; [
    cascadia-code
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
  ];

  # GTK & Cursor theme
  theme = "Adwaita";
  cursorTheme = "Adwaita";
  cursorSize = 24;

  # Hyprland settings
  hyprland = {
    terminal = "kitty";
    fileManager = "thunar";
    menu = "wofi --show drun";
    monitor = "eDP-1,1920x1080@144,0x0,1";
    backgroundPath = "/home/jc/nixos-config/backgrounds/shiho.jpg";
  };

}
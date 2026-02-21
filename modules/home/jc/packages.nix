{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:
let

  shutdownScript = pkgs.callPackage ../scripts/graceful-shutdown.nix {};
  volumeScript = pkgs.callPackage ../scripts/volume-control.nix {};
  brightnessScript = pkgs.callPackage ../scripts/brightness-control.nix {};
  lockScreenScript = pkgs.callPackage ../scripts/lock-screen.nix {};
  homeManagerScript = import ../scripts/apply-home-manager.nix { inherit pkgs config; };
  wallpaperScript = pkgs.callPackage ../scripts/change-wallpaper.nix {};
  # hdmiControlScript = pkgs.callPackage ../scripts/hdmi-control.nix {};  # Hyprland-specific
  # keybindsScript = pkgs.callPackage ../scripts/hyprland-keybinds.nix {};  # Hyprland-specific
in
{
  home.packages = with pkgs; [
    # Media and office applications
    vlc
    gthumb
    onlyoffice-desktopeditors # for office work
    # For reading EPUB, PDF and more
    kdePackages.okular
    
    # Development and virtual environments
    #distrobox # for sandboxing applications - open when docker or podman is installed
    python3Packages.uv # for virtual environments
    
    # Screenshots (niri has built-in screenshot, grim+slurp as backup)
    mission-center
    #nvtopPackages.nvidia
    
    # Entertainment
    ani-cli # for anime streaming
    python3Packages.yt-dlp
    
    # Custom scripts

    volumeScript
    brightnessScript
    lockScreenScript
    shutdownScript
    homeManagerScript
    wallpaperScript
    # hdmiControlScript  # Hyprland-specific
    # keybindsScript  # Hyprland-specific

    # AI CLI tools
    gemini-cli

    # IDE
    # vscode  # Commented out for niri migration
    antigravity-fhs
    cargo
    gcc

    # Browser
    tor-browser
    brave
  ];
}

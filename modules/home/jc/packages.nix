{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:
let
  lxcGui = pkgs.callPackage ../scripts/lxc-gui.nix {};
  shutdownScript = pkgs.callPackage ../scripts/graceful-shutdown.nix {};
  volumeScript = pkgs.callPackage ../scripts/volume-control.nix {};
  brightnessScript = pkgs.callPackage ../scripts/brightness-control.nix {};
  lockScreenScript = pkgs.callPackage ../scripts/lock-screen.nix {};
  homeManagerScript = import ../scripts/apply-home-manager.nix { inherit pkgs config; };
  wallpaperScript = pkgs.callPackage ../scripts/change-wallpaper.nix {};
  hdmiControlScript = pkgs.callPackage ../scripts/hdmi-control.nix {};
  keybindsScript = pkgs.callPackage ../scripts/hyprland-keybinds.nix {};
in
{
  home.packages = with pkgs; [
    # Media and office applications
    vlc
    gthumb
    onlyoffice-desktopeditors # for office work
    # For reading EPUB, PDF and more
    okular
    
    # Development and virtual environments
    #distrobox # for sandboxing applications - open when docker or podman is installed
    python313Packages.uv # for virtual environments
    
    # Screenshots and system monitoring
    flameshot # for screenshot
    grim
    mission-center
    nvtopPackages.nvidia
    
    # Entertainment
    ani-cli # for anime streaming
    python313Packages.yt-dlp
    
    # Custom scripts
    lxcGui
    volumeScript
    brightnessScript
    lockScreenScript
    shutdownScript
    homeManagerScript
    wallpaperScript
    hdmiControlScript
    keybindsScript

    # AI CLI tools
    gemini-cli

    # IDE
    vscode
    cargo
    gcc
  ];
}

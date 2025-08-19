{ config, pkgs, ... }:

let
  # Wrapper that runs the repo script with Python
  lxcGui = pkgs.writeShellScriptBin "lxc-gui" ''
    exec ${pkgs.python313Full}/bin/python ${./scripts/lxc_gui_standalone.py} "$@"
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
  };

  # Configuration
  xdg.configFile."starship.toml".source = ./.config/starship.toml;
  
  # Hyprland configuration
  xdg.configFile."hypr/hyprland.conf".source = ./.config/hypr/hyprland.conf;
}
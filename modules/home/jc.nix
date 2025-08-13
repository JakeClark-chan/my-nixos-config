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
    
    distrobox # for sandboxing applications
    python313Packages.uv # for virtual environments
    flameshot # for screenshot

    ani-cli # for anime streaming
    python313Packages.yt-dlp
    lxcGui
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
}
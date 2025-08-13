{ config, pkgs, ... }:

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
  ];

  # Git
  programs.git = {
    enable = true;
    userName = "JakeClark";
    userEmail = "jakeclark38b@gmail.com";
  };
  # ZSH
  # programs.zsh.enable = true;
}
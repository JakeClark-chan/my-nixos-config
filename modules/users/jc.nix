{ config, pkgs, ... }:

{
  users.users.jc = {
    isNormalUser = true;
    description = "JakeClark";
    # Add common groups: network, sudo, docker
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      vlc
      gthumb
      onlyoffice-desktopeditors # for office work
      
      distrobox # for sandboxing applications
      python313Packages.uv # for virtual environments
      flameshot # for screenshot

      ani-cli # for anime streaming
      python313Packages.yt-dlp
    ];
  };
}

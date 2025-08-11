{ config, pkgs, ... }:

{
  users.users.jc = {
    isNormalUser = true;
    description = "JakeClark";
    # Add common groups: network, sudo, docker
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      onlyoffice-desktopeditors # for office work
      vlc
      nodejs # for gemini cli and more
      vscode
      docker
      docker-compose
      python313Packages.uv
      flameshot # for screenshot
      distrobox # for sandboxing applications
    ];
  };
}

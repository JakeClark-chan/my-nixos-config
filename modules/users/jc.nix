{ config, pkgs, ... }:

{
  users.users.jc = {
    isNormalUser = true;
    description = "JakeClark";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      onlyoffice-desktopeditors
      openvpn
      nodejs
      docker
      docker-compose
      python313Packages.uv
      flameshot
      distrobox
    ];
  };
}

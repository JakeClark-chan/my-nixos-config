{ config, pkgs, ... }:

{
  users.users.jc = {
    isNormalUser = true;
    description = "JakeClark";
    # Add common groups: network, sudo, docker
    extraGroups = [ "networkmanager" "wheel" "docker" "lxd" ];
  };
}

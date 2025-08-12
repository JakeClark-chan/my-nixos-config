{ config, pkgs, ... }:

{
  # Virtualization
  #virtualisation.docker.enable = true;
  # virtualisation.lxc.enable = true;
  # virtualisation.lxd.enable = true;

  # Fix VS Code dynamic binaries and other FHS binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;
}

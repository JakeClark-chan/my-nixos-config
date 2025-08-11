{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  
  # Fix vscode dynamic binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;
}

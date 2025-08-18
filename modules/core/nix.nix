{ config, pkgs, ... }:

{
  # Enable experimental features.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Perform garbage collection weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  
  # Optimize storage
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}

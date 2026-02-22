{ config, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Binary cache
    substituters = [
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  
  # Set nix-channel to unstable for nix-shell and legacy commands
  nix.nixPath = [
    "nixpkgs=channel:nixos-unstable"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
  
  # Perform garbage collection weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  
  # Optimize storage
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;

  # Increase download buffer size to avoid slow cache downloads (default: 64 MiB)
  nix.settings.download-buffer-size = 268435456; # 256 MiB
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}

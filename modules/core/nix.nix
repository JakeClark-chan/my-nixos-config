{ config, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Binary caches - fetch pre-built packages instead of compiling
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
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

  # Limit build resources (prevents OOM on low-RAM machines)
  nix.settings.max-jobs = 2;
  nix.settings.cores = 2;

  # Increase download buffer size to avoid slow cache downloads (default: 64 MiB)
  nix.settings.download-buffer-size = 268435456; # 256 MiB
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}

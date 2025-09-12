{ config, pkgs, ... }:

{
  # Enable experimental features.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Set nix-channel to unstable for nix-shell and legacy commands
  nix.nixPath = [
    "nixpkgs=channel:nixos-unstable"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
  
  # Ensure unstable channel is set up system-wide
  systemd.services.setup-nix-channels = {
    description = "Setup NixOS unstable channels";
    wantedBy = [ "multi-user.target" ];
    after = [ "nix-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "setup-channels" ''
        # Add unstable channel for root if not already present
        if ! ${pkgs.nix}/bin/nix-channel --list | grep -q "nixos-unstable"; then
          ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
        fi
        
        # Update channels
        ${pkgs.nix}/bin/nix-channel --update
      '';
    };
  };
  
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

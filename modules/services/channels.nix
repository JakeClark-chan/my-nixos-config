{ config, pkgs, ... }:

{
  # Ensure unstable channel is available system-wide
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
  
  # Also set up channels for users on login
  environment.extraInit = ''
    # Ensure users have access to unstable channel
    if [ -n "$HOME" ] && [ -w "$HOME" ]; then
      if ! ${pkgs.nix}/bin/nix-channel --list 2>/dev/null | grep -q "nixpkgs"; then
        ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs 2>/dev/null || true
      fi
    fi
  '';
}

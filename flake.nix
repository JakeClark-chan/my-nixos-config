{
  # This is a simple NixOS flake
  # Use `sudo nix flake update` to update the flake
  # Use `sudo nixos-rebuild switch --flake .` to apply changes
  # Or one command: `sudo nixos-rebuild switch --recreate-lock-file --flake .`
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, here using the nixos-25.05 branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Unstable for selected packages
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # ---Snip---
    auto-cpufreq = {
        url = "github:AdnanHodzic/auto-cpufreq";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    # ---Snip---
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, auto-cpufreq, ... }@inputs: {
    # The host with the hostname `JakeClark-Sep21st` will use this configuration
    nixosConfigurations."JakeClark-Sep21st" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        # Overlay to get vscode from unstable
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (final: prev:
              let
                pkgsUnstable = import nixpkgs-unstable {
                  system = final.stdenv.hostPlatform.system;
                  config = final.config; # respects allowUnfree, etc.
                };
              in {
                lmstudio = pkgsUnstable.lmstudio;
                # If you use vscode-with-extensions, you can also map it here.
                # vscode-with-extensions = pkgsUnstable.vscode-with-extensions;
              })
          ];
        })

        ./configuration.nix
        auto-cpufreq.nixosModules.default
      ];
    };
  };
}
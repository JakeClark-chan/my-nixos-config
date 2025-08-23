{
  # This is a simple NixOS flake
  # Use `sudo nix flake update` to update the flake
  # Use `sudo nixos-rebuild switch --flake .` to apply changes
  # Or one command: `sudo nixos-rebuild switch --recreate-lock-file --flake .`
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the unstable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Auto-cpufreq for CPU frequency scaling (commented out - replaced with TLP)
    # auto-cpufreq = {
    #     url = "github:AdnanHodzic/auto-cpufreq";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };
    # Home Manager for user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # The host with the hostname `JakeClark-Sep21st` will use this configuration
    nixosConfigurations."JakeClark-Sep21st" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        # auto-cpufreq.nixosModules.default  # Commented out - replaced with TLP
        # Home Manager module for user configuration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          
          # Tie Home Manager to NixOS system generations
          home-manager.backupFileExtension = "backup";
          
          # Import user-specific home configuration
          home-manager.users.jc = import ./modules/home/jc.nix;

          # Pass system inputs to Home Manager
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

    # Standalone Home Manager configuration (for independent usage)
    homeConfigurations."jc" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ./modules/home/jc.nix
        {
          # Allow unfree packages for standalone Home Manager
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  };
}
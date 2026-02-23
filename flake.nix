{
  # This is a simple NixOS flake
  # Use `sudo nix flake update` to update the flake
  # Use `sudo nixos-rebuild switch --flake .` to apply changes
  # Or one command: `sudo nixos-rebuild switch --recreate-lock-file --flake .`
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the unstable branch (for niri cache compatibility)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Auto-cpufreq for CPU frequency scaling (commented out - replaced with TLP)
    # auto-cpufreq = {
    #     url = "github:AdnanHodzic/auto-cpufreq";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };
    # Home Manager for user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Zen Browser flake
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # PrismLauncher Cracked flake
    prismlauncher-cracked = {
      url = "github:Diegiwg/PrismLauncher-Cracked";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, prismlauncher-cracked, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    systemSettings = import ./modules/settings/system-settings.nix;
    desktopSettings = (import ./modules/settings/desktop-settings.nix) { inherit pkgs; };
    homeSettings = import ./modules/settings/home-settings.nix;
  in
  {
    # The host with the hostname from systemSettings will use this configuration
    nixosConfigurations.${systemSettings.hostname} = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs systemSettings desktopSettings homeSettings; };
      system = system;
      modules = [
        ./configuration.nix
        # Home Manager module for user configuration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs systemSettings desktopSettings homeSettings; };
        }
      ];
    };

    # Standalone Home Manager configuration (for independent usage)
    homeConfigurations.${systemSettings.username} = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;
      extraSpecialArgs = { inherit inputs systemSettings desktopSettings homeSettings; };
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
{ config, pkgs, ... }:

{
  # Import general desktop settings
  imports = [
    ./general.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
}

{ config, pkgs, ... }:

{
  networking.hostName = "JakeClark-Sep21st";
  networking.networkmanager.enable = true;
  
  # Disable printing
  services.printing.enable = false;
}

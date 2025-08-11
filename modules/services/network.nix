{ config, pkgs, ... }:

{
  # Define your hostname.
  networking.hostName = "JakeClark-Sep21st";
  # Enable networking via NetworkManager
  networking.networkmanager.enable = true;
  
  # Disable printing service (CUPS)
  services.printing.enable = false;
}

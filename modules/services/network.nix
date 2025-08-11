{ config, pkgs, ... }:

{
  # Define your hostname.
  networking.hostName = "JakeClark-Sep21st";
  # Enable networking via NetworkManager
  networking.networkmanager.enable = true;
  
  # Disable printing service (CUPS)
  services.printing.enable = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ]; # HTTP, HTTPS
    allowedUDPPorts = [ 53 ]; # DNS
  };
}

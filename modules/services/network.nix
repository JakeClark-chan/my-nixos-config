{ config, pkgs, systemSettings, ... }:

{
  # Define your hostname.
  networking.hostName = systemSettings.hostname;
  
  # Enable nftables (required for Incus on NixOS)
  networking.nftables.enable = true;
  
  # Enable networking via NetworkManager
  networking.networkmanager = {
    enable = true;
    # Auto-connect to known networks
    settings = {
      main = {
        # Automatically connect to networks
        no-auto-default = false;
      };
      # WiFi settings
      wifi = {
        # Scan for networks more frequently
        scan-rand-mac-address = false;
        # Enable powersave
        powersave = 2;
      };
    };
  };
  # Additional hosts
  networking.extraHosts = ''
    10.0.0.100 target
  '';

  # Wireless firmware support
  
  # Enable wireless support
  hardware.enableRedistributableFirmware = true;
  
  # Additional networking packages
  environment.systemPackages = with pkgs; [
    networkmanagerapplet  # GUI for NetworkManager
    wirelesstools        # iwconfig, iwlist, etc.
  ];
  
  # Disable printing service (CUPS)
  services.printing.enable = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    enable = false;
    # allowedTCPPorts = [ 80 443 ]; # HTTP, HTTPS
    # allowedUDPPorts = [ 53 ]; # DNS
  };
}

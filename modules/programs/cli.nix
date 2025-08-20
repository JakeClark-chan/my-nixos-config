{ config, pkgs, ... }:

{
  # CLI Tools and System Utilities
  environment.systemPackages = with pkgs; [
    # Network utilities
    wget
    curl
    openvpn
    
    # System utilities
    usbutils         # for lsusb
    usb-modeswitch   # for usb_modeswitch
    fastfetch        # system info
    htop             # process monitor
    ncdu             # disk usage analyzer
    jq               # JSON processor
    kbd              # for setleds (lock key state checking)
    
    # Shell and terminal
    zsh
    starship         # shell prompt
    
    # Version control
    git
  ];
}

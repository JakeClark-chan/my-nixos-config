{ config, pkgs, ... }:

{
  # Install Firefox browser
  programs.firefox.enable = true;

  # Enable SSH agent for convenience
  programs.ssh = {
    startAgent = true;
  };
  
  # Common CLI tools and languages
  environment.systemPackages = with pkgs; [
    wget
    curl
    usbutils # for lsusb
    usb-modeswitch # for usb_modeswitch
    zsh
    python313
    git
    openvpn
    fastfetch
    htop
  ];
}

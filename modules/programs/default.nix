{ config, pkgs, ... }:

{
  programs.firefox.enable = true;

  programs.ssh = {
    startAgent = true;
  };
  
  environment.systemPackages = with pkgs; [
    wget
    curl
    usbutils
    usb-modeswitch
    zsh
    python313
    git
  ];
}

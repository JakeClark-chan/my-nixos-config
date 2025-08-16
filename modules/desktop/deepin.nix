{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the Deepin Desktop Environment and LightDM.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.deepin.enable = true;
  
  # Configure keymap in X11.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jc";
  
  # Custom background
  # This script copies background to /usr/share/backgrounds - Deepin only.
  # Copy your image into the repo (e.g., shiho.jpg) and it will be installed system-wide.
  environment.systemPackages = with pkgs; [
    (pkgs.runCommand "custom-background" { } ''
      mkdir -p $out/share/backgrounds
      cp ${../../shiho.jpg} $out/share/backgrounds/
    '')
    deepin.deepin-reader
  ];
}

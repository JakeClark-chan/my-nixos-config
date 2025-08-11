{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.deepin.enable = true;
  
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  
  # Auto login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jc";
  
  # Custom background
  environment.systemPackages = with pkgs; [
    (pkgs.runCommand "custom-background" { } ''
      mkdir -p $out/share/backgrounds
      cp ${../../shiho.jpg} $out/share/backgrounds/
    '')
  ];
}

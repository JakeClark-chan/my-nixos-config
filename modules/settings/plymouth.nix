{ config, pkgs, ... }:
let
  myPlymouthTheme = pkgs.stdenv.mkDerivation {
    name = "my-theme";
    src = ./plymouth-themes/my-theme;
    
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/my-theme
      cp -r * $out/share/plymouth/themes/my-theme/
      
      # Replace @out@ placeholder with actual output path
      substituteInPlace $out/share/plymouth/themes/my-theme/my-theme.plymouth \
        --replace "@out@" "$out"
    '';
  };
in
{
  boot = {
    plymouth = {
      enable = true;
      theme = "my-theme";
      themePackages = [ 
        pkgs.plymouth 
        myPlymouthTheme
      ];
    };
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };
}

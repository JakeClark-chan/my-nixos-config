{ config, pkgs, ... }:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "my-theme";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          name = "my-plymouth-theme";
          src = ./plymouth-themes/my-theme;  # put theme files here
          installPhase = ''
            mkdir -p $out/share/plymouth/themes/my-theme
            cp -r * $out/share/plymouth/themes/my-theme/
          '';
        })
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
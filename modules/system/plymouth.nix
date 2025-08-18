{ config, pkgs, ... }:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "breeze";
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

  # # Create custom theme
  # boot.plymouth.themePackages = [
  #   (pkgs.stdenv.mkDerivation {
  #     name = "my-plymouth-theme";
  #     src = ./plymouth-themes/my-theme;  # put theme files here
  #     installPhase = ''
  #       mkdir -p $out/share/plymouth/themes/my-theme
  #       cp -r * $out/share/plymouth/themes/my-theme/
  #     '';
  #   })
  # ];
  # boot.plymouth.theme = "my-theme";  # use your custom theme
}
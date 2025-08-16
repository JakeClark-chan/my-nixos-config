{ config, pkgs, ... }:

{
  # Enable Plymouth boot splash
  boot.plymouth.enable = true;
  
  # Disable Plymouth password prompts during boot
  boot.initrd.systemd.emergencyAccess = false;

  boot.plymouth.theme = "breeze";
  
  # # Add kernel parameters to slow down boot for testing
  # boot.kernelParams = [
  #   "quiet"          # Hide kernel messages
  #   "splash"         # Enable splash screen
  #   "plymouth.ignore-serial-consoles"
  # ];
  
  # # Add artificial delay to see Plymouth (remove after testing)
  # boot.initrd.systemd.services.plymouth-delay = {
  #   description = "Delay to see Plymouth";
  #   wantedBy = [ "initrd.target" ];
  #   before = [ "initrd.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.coreutils}/bin/sleep 10";
  #   };
  # };

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
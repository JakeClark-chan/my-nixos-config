{ config, pkgs, ... }:

{
  # Enable Plymouth boot splash
  boot.plymouth.enable = true;
  # Use a built-in theme
  #boot.plymouth.theme = "breeze";  # or "bgrt", "spinner", "text"
  
  # OR create custom theme
  boot.plymouth.themePackages = [
    (pkgs.stdenv.mkDerivation {
      name = "my-plymouth-theme";
      src = ./plymouth-themes/my-theme;  # put theme files here
      installPhase = ''
        mkdir -p $out/share/plymouth/themes/my-theme
        cp -r * $out/share/plymouth/themes/my-theme/
      '';
    })
  ];
  boot.plymouth.theme = "my-theme";  # use your custom theme
}
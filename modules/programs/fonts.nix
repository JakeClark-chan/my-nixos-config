{ config, pkgs, ... }:

{
  # Font configurations
  fonts.packages = with pkgs; [
    # System fonts
    # nerd-fonts.fira-code
    cascadia-code

    # Custom fonts from repo
    (pkgs.stdenv.mkDerivation {
      name = "my-custom-fonts";
      src = ../fonts;  # put TTF files in modules/fonts/
      installPhase = ''
        install -Dm644 *.ttf -t $out/share/fonts/truetype/
      '';
    })
  ];
}

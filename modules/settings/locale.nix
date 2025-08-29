{ config, pkgs, systemSettings, ... }:

{
  # Set your time zone.
  time.timeZone = systemSettings.timezone;
  
  # Select internationalisation properties.
  i18n.defaultLocale = systemSettings.locale;
  i18n.extraLocaleSettings = systemSettings.extraLocaleSettings;
  
  # Fcitx5 input method
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-bamboo
      fcitx5-nord
    ];
  };
}

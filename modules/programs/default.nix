{ config, pkgs, inputs, ... }:

{
  # Install Firefox browser
  programs.firefox.enable = true;

  # Enable SSH agent for convenience
  programs.ssh = {
    startAgent = true;
  };

  # Enable auto-cpufreq for CPU frequency scaling
  programs.auto-cpufreq.enable = true;
  # optionally, you can configure your auto-cpufreq settings, if you have any
  programs.auto-cpufreq.settings = {
    charger = {
      governor = "performance"; # cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
      turbo = "auto"; # (always, auto, or never)
      energy_performance_preference = "balance_performance"; # cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
      energy_perf_bias = "balance_performance"; # performance (0), balance_performance (4), default (6), balance_power (8), or power (15)
      platform_profile = "balance"; # cat /sys/firmware/acpi/platform_profile_choices
    };

    battery = {
      governor = "powersave";
      turbo = "never";
      energy_performance_preference = "power";
      energy_perf_bias = "power";
      platform_profile = "balance";
    };
  };
  
  # Common CLI tools and languages
  environment.systemPackages = with pkgs; [
    wget
    curl
    usbutils # for lsusb
    usb-modeswitch # for usb_modeswitch
    zsh
    python313Full
    git
    openvpn
    fastfetch
    htop
    ncdu
    jq
    starship

    nodejs # for gemini cli and more
    vscode_unstable
    lmstudio_unstable
    #docker-compose
  ];

  fonts.packages = with pkgs; [
    # Add your preferred fonts here
    # e.g., noto-fonts, dejavu_fonts, etc.
    nerd-fonts.fira-code 
    cascadia-code

    # Custom fonts
    (pkgs.stdenv.mkDerivation {
      name = "my-custom-fonts";
      src = ../fonts;  # put TTF files in modules/fonts/
      installPhase = ''
        install -Dm644 *.ttf -t $out/share/fonts/truetype/
      '';
    })
  ];
}

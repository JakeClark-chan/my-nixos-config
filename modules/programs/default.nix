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
      governor = "performance";
      turbo = "auto";
      energy_performance_preference = "performance";
      energy_perf_bias = "balance_performance";
      platform_profile = "performance";
    };

    battery = {
      governor = "powersave";
      turbo = "never";
      energy_performance_preference = "power";
      energy_perf_bias = "power";
      platform_profile = "quiet";
    };
  };
  
  # Common CLI tools and languages
  environment.systemPackages = with pkgs; [
    wget
    curl
    usbutils # for lsusb
    usb-modeswitch # for usb_modeswitch
    zsh
    python313
    git
    openvpn
    fastfetch
    htop
    ncdu
    jq

    nodejs # for gemini cli and more
    vscode
    docker
    docker-compose
  ];
}

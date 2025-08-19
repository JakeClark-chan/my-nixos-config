{ config, pkgs, ... }:

{
  # Development Tools and Languages
  environment.systemPackages = with pkgs; [
    # Programming languages
    python313Full
    nodejs           # for gemini cli and more
    
    # Editors and IDEs
    vscode_unstable
    
    # AI/ML Tools
    # lmstudio_unstable
    
    # Container tools (commented - enable as needed)
    #docker-compose
  ];
  
  # System programs configuration
  programs.firefox.enable = true;

  # Enable SSH agent for convenience
  programs.ssh = {
    startAgent = true;
  };

  # Enable auto-cpufreq for CPU frequency scaling
  programs.auto-cpufreq.enable = true;
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
}

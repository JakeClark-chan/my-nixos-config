{ config, pkgs, ... }:

{
  # Development Tools and Languages
  environment.systemPackages = with pkgs; [
    # Programming languages
    python313Full
    nodejs           # for gemini cli and more
    
    # Editors and IDEs
    vscode
    
    # AI/ML Tools
    # lmstudio
    
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
      governor = "performance";
      turbo = "auto";
      energy_performance_preference = "balance_performance";
      # Remove energy_perf_bias as it might not be supported on this CPU
      platform_profile = "balance";
    };

    battery = {
      governor = "powersave";
      turbo = "never";
      energy_performance_preference = "power";
      # Remove energy_perf_bias as it might not be supported on this CPU  
      platform_profile = "balance";
    };
  };
}

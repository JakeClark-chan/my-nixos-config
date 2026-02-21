{ config, pkgs, inputs, ... }:

{
  # Development Tools and Languages
  environment.systemPackages = with pkgs; [
    # Programming languages
    python3
    nodejs           # for gemini cli and more
    
    # Editors and IDEs
    neovim
    # Fallback
    gedit

    # Java
    temurin-bin
    glib               # For JavaFX GTK backend
    
    # AI/ML Tools
    n8n
    
    # Container tools (commented - enable as needed)
    docker-compose

    # Zen Browser
    # inputs.zen-browser.packages."${pkgs.system}".default
    
    # PrismLauncher Cracked
    # inputs.prismlauncher-cracked.packages."${pkgs.system}".default
    # Steam run for prism-launcher
    steam-run
  ];
  
  # System programs configuration
  # No Firefox
  # programs.firefox.enable = true;
  # Zen Browser configuration (Firefox-based browser)

  # Ollama Services (removed)
  # services.ollama = {
  #   enable = true;
  #   loadModels = [ "qwen3:1.7b" ];
  # };

  # Ollama UI (removed)
  # services.nextjs-ollama-llm-ui = {
  #   enable = true;
  # };

  # n8n Service (removed)
  # services.n8n = {
  #   enable = true;
  # };

  # Enable SSH agent for convenience
  programs.ssh = {
    startAgent = true;
  };

  # CPU performance scaling with TLP
  # Enable TLP for power management - use tlp-stat -c or --cdiff for comparison
  services.tlp = {
    enable = true;
    settings = {
      # Force to use battery mode
      # TLP_DEFAULT_MODE = "BAT";
      # TLP_PERSISTENT_DEFAULT = 1;

      # Sound power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 10;

      # Disk
      SATA_LINKPWR_ON_BAT="min_power";

      # Graphic card
      INTEL_GPU_MAX_FREQ_ON_BAT=800000;
      INTEL_GPU_BOOST_FREQ_ON_BAT=800000;

      # Kernel
      NMI_WATCHDOG=0;

      # Wifi
      WOL_DISABLE="Y";
      WIFI_PWR_ON_AC="off";
      WIFI_PWR_ON_BAT="off";

      # Platform profile
      PLATFORM_PROFILE_ON_AC="performance";
      PLATFORM_PROFILE_ON_BAT="quiet"; # Reduce noise and power consumption

      # Memory sleep
      MEM_SLEEP_ON_AC="s2idle";
      MEM_SLEEP_ON_BAT="deep";

      # Processor
      CPU_DRIVER_OPMODE_ON_AC="active";
      CPU_DRIVER_OPMODE_ON_BAT="passive";

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 60;

      CPU_BOOST_ON_AC=1;
      CPU_BOOST_ON_BAT=0;

      CPU_HWP_DYN_BOOST_ON_AC=1;
      CPU_HWP_DYN_BOOST_ON_BAT=0;

      # Runtime power management for pcie device
      RUNTIME_PM_ON_AC="auto";
      RUNTIME_PM_ON_BAT="auto";

      # PCIE active state power management
      PCIE_ASPM_ON_AC="default";
      PCIE_ASPM_ON_BAT="powersave";

      # USB autosuspend
      USB_AUTOSUSPEND=1;
      USB_DENYLIST="0bda:b711 1c4f:0048"; # WiFi adapter and USB mouse
    };
  };

  # Commented out auto-cpufreq configuration (replaced with TLP)
  # programs.auto-cpufreq.enable = true;
  # programs.auto-cpufreq.settings = {
  #   charger = {
  #     governor = "performance";
  #     turbo = "auto";
  #     energy_performance_preference = "balance_performance";
  #     # Remove energy_perf_bias as it might not be supported on this CPU
  #     platform_profile = "balance";
  #   };

  #   battery = {
  #     governor = "powersave";
  #     turbo = "never";
  #     energy_performance_preference = "power";
  #     # Remove energy_perf_bias as it might not be supported on this CPU  
  #     platform_profile = "balance";
  #   };
  # };
}

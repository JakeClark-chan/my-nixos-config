{ config, pkgs, systemSettings, desktopSettings, homeSettings, ... }:

{
  # Desktop launchers and entries
  xdg.desktopEntries = {

    # Zen Browser with PRIME
    # zen = {
    #   name = "Zen Browser (with Prime)";
    #   comment = "Web browser";
    #   exec = "prime-run zen";
    #   terminal = false;
    #   categories = [ "Utility" "System" ];
    # };

    # PrismLauncher with Steam runtime
    prismlauncher = {
      name = "Prism Launcher (with Steam)";
      comment = "Minecraft launcher";
      exec = "steam-run prismlauncher";
      terminal = false;
      categories = [ "Utility" ];
    };

    # Graceful shutdown
    graceful-shutdown = {
      name = "Graceful Shutdown";
      comment = "Gracefully shutdown the system";
      exec = "graceful-shutdown shutdown";
      terminal = false;
      icon = "system-shutdown";
      categories = [ "System" ];
    };
    
    # Graceful reboot
    graceful-reboot = {
      name = "Graceful Reboot";
      comment = "Gracefully reboot the system";
      exec = "graceful-shutdown reboot";
      terminal = false;
      icon = "system-reboot";
      categories = [ "System" ];
    };
  };
}

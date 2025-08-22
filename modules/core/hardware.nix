{ config, pkgs, ... }:

{
  # Hardware-specific configurations
  # Disable Bluetooth
  hardware.bluetooth = {
    enable = false;
    powerOnBoot = false;
  };

  # Enable non-redistributable and all firmware bundles
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];

  # Install Intel VA-API driver for hardware video acceleration
  environment.systemPackages = with pkgs; [
    intel-media-driver
    libva-utils
  ];

  # Load Realtek USB Wi-Fi driver
  boot.kernelModules = [ "rtl8xxxu" ];
  # Use a specific kernel version
  # Uncomment the line below to use the latest kernel version
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15; # Stable kernel version
  
  # USB mode switching and battery threshold rules
  services.udev.packages = [ pkgs.usb-modeswitch ];
  services.udev.extraRules = ''
    # Realtek USB device mode switch
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", \
      RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -K -v 0bda -p 1a2b"

    # Set battery charge limit for ASUS laptops
    ACTION=="add", KERNEL=="asus-nb-wmi", \
      RUN+="${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold'"
  '';

  # # Enable NVIDIA PRIME for hybrid graphics
  # services.xserver.videoDrivers = [ "nvidia" ];

  # hardware.nvidia = {
  #   open = false; # open source drivers
  #   modesetting.enable = true;
  #   nvidiaSettings = false;              # installs nvidia-settings
  #   powerManagement.enable = true;      # optional: saves power on laptops
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };
  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   offload.enableOffloadCmd = true; # enables offload command
  #   offload.offloadCmdMainProgram = "prime-run"; # command to run with offload
  #   intelBusId = "PCI:0@0:2:0";   # replace with your iGPU
  #   nvidiaBusId = "PCI:1@0:0:0";  # replace with your dGPU
  # };

  # Instruction for NVIDIA Optimus users:
  # To use NVIDIA GPU, run `prime-run` command
  # don't set hardware.nvidiaOptimus.disable because error will occur
}

{ config, pkgs, ... }:

{
  # Hardware-specific configurations
  # Disable Bluetooth
  hardware.bluetooth = {
    enable = false;
    powerOnBoot = false;
  };

  # Look at https://wiki.nixos.org/wiki/Accelerated_Video_Playback
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ 
      intel-media-driver
      intel-vaapi-driver
      libva
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  # Enable non-redistributable and all firmware bundles
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];

  # Load Realtek USB Wi-Fi driver
  boot.kernelModules = [ "rtl8xxxu" ];
  
  # WiFi driver options (equivalent to /etc/modprobe.d/wifi.conf)
  # Uncomment this if below code is not commented
  # boot.extraModprobeConfig = ''
  #   options mt7921e disable_aspm=1
  # '';
  
  # Use a stable kernel version
  # Default stable kernel (for current LTS version)
  boot.kernelPackages = pkgs.linuxPackages;
  # Alternative specific stable versions:
  # boot.kernelPackages = pkgs.linuxPackages_6_11; # Specific stable version, but be aware of non-LTS cause Nix unstable will remove EOL kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest; # Latest mainline (not recommended for stability)
  # Check EOL status at https://www.kernel.org/
  
  # USB mode switching and battery threshold rules
  services.udev.packages = [ pkgs.usb-modeswitch ];
  # Uncomment this if below code is not commented
  # services.udev.extraRules = ''
  #   # Realtek USB device mode switch
  #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", \
  #     RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -K -v 0bda -p 1a2b"

  #   # Set battery charge limit for ASUS laptops - disable since we will use tlp instead
  #   ACTION=="add", KERNEL=="asus-nb-wmi", \
  #     RUN+="${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold'"
  # '';

  # Enable NVIDIA PRIME for hybrid graphics
  # services.xserver.videoDrivers = [ "nvidia" ];

  # hardware.nvidia = {
  #   open = false; # open source drivers
  #   modesetting.enable = true;
  #   nvidiaSettings = false;              # installs nvidia-settings
  #   powerManagement.enable = true;      # optional: saves power on laptops
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  #   powerManagement.finegrained = true;
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

  # Instruction to disable dGPU completely: comment above and uncomment these
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
    options mt7921e disable_aspm=1
  '';
    
  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
    # Realtek USB device mode switch
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", \
      RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -K -v 0bda -p 1a2b"

    # Set battery charge limit for ASUS laptops - disable since we will use tlp instead
    ACTION=="add", KERNEL=="asus-nb-wmi", \
      RUN+="${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold'"
  '';
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];

}

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
  
  # Use latest kernel and load Realtek USB Wi-Fi driver
  boot.kernelModules = [ "rtl8xxxu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
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
}

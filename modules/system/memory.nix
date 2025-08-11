{ config, pkgs, ... }:

{
  # Swap configuration
  swapDevices = [{
    device = "/swapfile";
    size = 4 * 1024; # 4GB
    priority = 10;
  }];

  # Zram Swap
  zramSwap = {
    enable = true;
    memoryPercent = 30;
    algorithm = "lz4";
    priority = 100;
  };
}

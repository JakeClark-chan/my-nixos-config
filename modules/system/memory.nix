{ config, pkgs, ... }:

{
  # Swap configuration
  swapDevices = [{
  device = "/swapfile";   # Path where swapfile will be created
  size = 4 * 1024; # Size in MiB (4GB)
  priority = 10;   # Priority of the swap device
  }];

  # Zram Swap
  zramSwap = {
  enable = true;        # Enable zram swap
  memoryPercent = 30;
  algorithm = "lz4";   # Compression algorithm to use
  priority = 100;       # Priority of the zram swap device
  };
}

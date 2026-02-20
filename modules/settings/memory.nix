{ config, pkgs, ... }:

{
  # Swap configuration
  swapDevices = [{
  device = "/swapfile";   # Path where swapfile will be created
  size = 6 * 1024; # Size in MiB (6GB)
  priority = 10;   # Priority of the swap device
  }];

  # Zram Swap
  zramSwap = {
  enable = true;        # Enable zram swap
  memoryPercent = 120;  # Go beyond 8GB RAM to 120% of zram
  algorithm = "zstd";   # Compression algorithm to use
  priority = 100;       # Priority of the zram swap device
  };
}

{ config, pkgs, ... }:

{
  # Virtualization
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = false;  # Keep using system Docker
      setSocketVariable = false;
    };
    # Set custom data directory
    daemon.settings = {
      data-root = "/home/jc/docker";
    };
  };

  virtualisation.incus = {
    enable = true;
    ui.enable = true;

    # Configure Incus to use custom data directory
    # Look at https://documentation.ubuntu.com/lxd/latest/reference/preseed_yaml_fields/#preseed-yaml-file-fields
    preseed = {
      networks = [
        {
          name = "lxdbr0"; # Because configuration examples use lxdbr0 by default
          type = "bridge";
          config = {
            "ipv4.address" = "10.0.0.1/24";
            "ipv4.nat" = "true";
            "ipv4.dhcp" = "true";
          };
        }
      ];
      profiles = [
        {
          name = "default";
          devices = {
            eth0 = {
              name = "eth0";
              network = "lxdbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              size = "7GiB";
              type = "disk";
            };
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "dir";
          config = {
            source = "/home/jc/incus/storage-pools/default";
          };
        }
      ];
    };
  };

  # Create directories with proper ownership
  systemd.tmpfiles.rules = [
    "d /home/jc/incus 0755 root root -"
    "d /home/jc/incus/storage-pools 0755 root root -"
    "d /home/jc/incus/storage-pools/default 0755 root root -"
    "d /home/jc/incus 0755 root root -"
    "d /home/jc/docker 0755 jc jc -"
  ];

  # Enable Waydroid https://wiki.nixos.org/wiki/Waydroid
  virtualisation.waydroid.enable = true;
  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  # Fix VS Code dynamic binaries and other FHS binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld;
}

{ config, pkgs, ... }:

{
  # Btrfs maintenance services

  # Weekly scrub to detect and fix data corruption
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  # Monthly balance to optimize data/metadata chunk usage
  systemd.services.btrfs-balance = {
    description = "Btrfs balance (monthly)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=50 -musage=50 /";
    };
  };

  systemd.timers.btrfs-balance = {
    description = "Monthly Btrfs balance timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "6h";
    };
  };

  # SSD TRIM support
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
}

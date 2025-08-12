{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.mine.lxc;

  format = pkgs.formats.json { };

  preseedFile = format.generate "preseed.yaml" cfg.preseed;

in {

  options.mine.lxc = {
    enable = mkEnableOption "lxc";

    zfsPool = mkOption {
      type = types.str;
      example = "main/local/lxc";
    };

    preseed = mkOption {
      default = { };
      type = format.type;
      example = literalExpression ''
        {
          config = {
            "images.auto_update_interval" = 15;
          };
        };
      '';
      description = ''
        LXD preseed extra configuration. See
        <link xlink:href="https://linuxcontainers.org/lxd/docs/master/preseed/">
        the documentation</link> for a list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    mine.lxc.preseed = {
      networks = [{
        name = "lxdbr0";
        type = "bridge";
        config = {
          "ipv4.address" = "10.200.0.1/24";
          "ipv6.address" = "fd42::1/64";
        };
      }];

      storage_pools = [{
        name = "default";
        driver = "zfs";
        config.source = cfg.zfsPool;
      }];

      profiles = [{
        name = "default";
        devices.eth0 = {
          name = "eth0";
          network = "lxdbr0";
          type = "nic";
        };
        devices.root = {
          path = "/";
          pool = "default";
          type = "disk";
        };
      }];
    };

    virtualisation.lxd = {
      enable = true;
      zfsSupport = true;
      recommendedSysctlSettings = true;
    };

    virtualisation.lxc = {
      enable = true;
      lxcfs.enable = true;
      defaultConfig = ''
        lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf
      '';
    };

    systemd.services."lxd-preseed" = {
      description = "Preseed LXD";
      wantedBy = [ "multi-user.target" ];
      requires = [ "lxd.socket" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writers.writeDash "preseed" ''
          cat ${preseedFile} | ${pkgs.lxd}/bin/lxd init --preseed
        '';
      };
    };

  };

}
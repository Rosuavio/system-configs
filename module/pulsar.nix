{ pkgs, ... }:
let
  sources = import ../npins;

  inherit (sources) nixos-hardware;
in
{
  imports =
    [
      "${nixos-hardware}/lenovo/thinkpad/t480"
      "${nixos-hardware}/common/cpu/intel/kaby-lake"
      ./default.nix
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];

      systemd.services.rollback = {
        description = "Rollback ZFS datasets to a pristine state";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          "zfs-import-zpool.service"
        ];
        before = [
          "sysroot.mount"
        ];
        path = with pkgs; [
          zfs
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r zpool/local/root@blank && echo "rollback complete"
        '';
      };

      kernelModules = [ "kvm-intel" ];
    };
  };

  fileSystems = {
    "/" = {
      device = "zpool/local/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "zpool/local/nix";
      fsType = "zfs";
    };
    "/persist" = {
      device = "zpool/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/home" = {
      device = "zpool/safe/home";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/AF3D-55A6";
      fsType = "vfat";
    };
  };

  powerManagement.cpuFreqGovernor = "powersave";

  # TODO: Validate I want the effects of this.
  services.thermald.enable = true;
  services.udisks2.enable = true;

  networking.hostName = "pulsar";
  networking.hostId = "f696fe6c";
}

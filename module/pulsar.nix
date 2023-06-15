let
  sources = import ../nix/sources.nix;

  inherit (sources) nixos-hardware;
in
{
  imports =
    [
      "${nixos-hardware}/lenovo/thinkpad/t480"
      "${nixos-hardware}/common/cpu/intel/kaby-lake"
      ./default.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

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
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
  };

  networking.hostName = "pulsar";
  networking.hostId = "f696fe6c";
}

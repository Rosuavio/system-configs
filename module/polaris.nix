{ pkgs, ... }:
let
  sources = import ../npins;

  hostName = "polaris";

  inherit (sources) nixos-hardware;
in
{
  imports =
    [
      "${nixos-hardware}/common/cpu/amd"
      "${nixos-hardware}/common/cpu/amd/pstate.nix"
      "${nixos-hardware}/common/gpu/amd"
      "${nixos-hardware}/common/pc/ssd"
      "${nixos-hardware}/common/pc"
      "${nixos-hardware}/common/hidpi.nix"
      ./default.nix
    ];

  boot.kernelModules = [ "kvm-amd" ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "uas" "usbhid" "sd_mod" ];

  fileSystems."/" =
    {
      device = "mainpool/local/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "mainpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "mainpool/safe/home";
      fsType = "zfs";
    };

  fileSystems."/persist" =
    {
      device = "mainpool/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/7825-1D31";
      fsType = "vfat";
    };

  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      "zfs-import-mainpool.service"
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
      zfs rollback -r mainpool/local/root@blank && echo "rollback complete"
    '';
  };

  boot.plymouth.enable = true;
  boot.zfs.forceImportRoot = false;

  hardware = {
    openrazer = {
      enable = true;
      users = [ "rosario" ];
    };
  };

  # Fix for B550I-AORUS-PRO-AX
  # TODO: Instead of greping threw I would like a static path to check
  powerManagement.powerDownCommands = ''
    if (grep "GPP0.*enabled" /proc/acpi/wakeup > /dev/null); then
        echo GPP0 > /proc/acpi/wakeup
    fi
  '';

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
    fuse3
    sbctl
  ];

  users.users = {
    rosario = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDrofEHtfNnlLRqi2zb5XmJOvXPlm6eU6XK5YhTgFnB rosario@pulsar"
      ];
    };
  };

  networking.hostName = hostName;
  networking.hostId = "6a82d7b3";
}

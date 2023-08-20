{ pkgs, ... }:
let
  sources = import ../nix/sources.nix;

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

  boot.kernelModules = [ "kvm-amd" "btqca" "btusb" "hci_qca" "hci_uart" "sg" "btintel" ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "uas" "usbhid" "sd_mod" ];

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

  boot.plymouth.enable = true;
  boot.zfs.forceImportRoot = false;

  hardware = {
    openrazer = {
      enable = true;
      users = [ "rosario" ];
    };
  };

  systemd.services = {
    # Maybe try to figure out whats going on with this device. Try a bios update.
    # B550I-AORUS-PRO-AX
    suspend-fix = {
      enable = true;

      wants = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Description = "Disable GPP0 to fix suspend issue";
        Type = "simple";
        ExecStart =
          "${pkgs.bashInteractive}/bin/sh -c \"${pkgs.coreutils}/bin/echo GPP0 > /proc/acpi/wakeup\"";
      };
    };
  };

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

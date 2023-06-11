{ pkgs, lib, ... }:
let
  sources = import ../nix/sources.nix;

  hostName = "polaris";

  inherit (sources) nixos-hardware;
  suspend-fix = pkgs.writeShellScriptBin "suspend-fix" ''
    #!/usr/bin/env bash
    isenabled=`cat /proc/acpi/wakeup | grep $1 | grep -o enabled`
    if [ $isenabled == "enabled" ]; then
      echo $1 > /proc/acpi/wakeup
    else
      exit
    fi
  '';
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

  boot.kernelModules = [ "btqca" "btusb" "hci_qca" "hci_uart" "sg" "btintel" ];

  boot.plymouth.enable = true;

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
        Type = "simple";
        ExecStart = lib.getExe suspend-fix + " GPP0";
      };
    };
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };

    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
    fuse3
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

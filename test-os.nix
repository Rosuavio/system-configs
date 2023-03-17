{ config, pkgs, lib, modulesPath, ...}:
{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ./module.nix
  ];

  virtualisation = {
    memorySize = 1024 * 4;
    diskSize = 1024 * 2;
    cores = 2;
    # NOTE: Blindly coppied from
    # https://discourse.nixos.org/t/problem-with-sway-in-nixos-rebuild-build-vm-how-to-configure-vm/20263/3
    qemu.options = [
      "-vga none"
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
  };

  networking.hostId = "759df4cd";
  users.users = {
    root.password = "test";
    rosario.password = "test";
  };

  # TODO: Migrate this into the system config.
  system.stateVersion = "22.11";
}

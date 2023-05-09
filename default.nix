{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, nixos ? nixpkgs + "/nixos"
, pkgs ? import nixpkgs {}
, ...
}:
{
  mkRebuildScript = nixpkgs-path: nixos-config-path:
    pkgs.writeShellScriptBin "nixos-rebuild" ''
        exec ${pkgs.nixos-rebuild}/bin/nixos-rebuild \
          -I nixpkgs=${nixpkgs-path} \
          -I nixos-config=${nixos-config-path} \
          "$@"
      '';
  vm =
    (import nixos {
      configuration = { config, pkgs, lib, modulesPath, ...}: {
        imports = [
          (modulesPath + "/virtualisation/qemu-vm.nix")
          ./module
          ./default-config.nix
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
      };
    }).vm;
}

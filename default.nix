{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, ...
}:
let
  nixpkgs-path = nixpkgs;
  nixos-path = nixpkgs-path + "/nixos";
  nix-pre-commit-hooks = import sources."pre-commit-hooks.nix";

in
{
  inherit nixpkgs;
  pre-commit-check = nix-pre-commit-hooks.run {
    # Might want to see about using oxalica/nil (an interesting nix language server) for linting.
    src = ./.;
    hooks = {
      statix.enable = true;
      deadnix = {
        enable = true;
        excludes = [ "^nix\\/.*$" ];
      };
      nixpkgs-fmt = {
        enable = true;
        excludes = [ "^nix\\/.*$" ];
      };
    };

    settings = {
      statix.ignore = [ "nix/**" ];
    };
  };

  mkRebuildScript =
    { nixos-config
    , nixpkgs ? nixpkgs-path
    , pkgs ? import nixpkgs { }
    }:
    pkgs.writeShellScriptBin "nixos-rebuild" ''
      exec ${pkgs.nixos-rebuild}/bin/nixos-rebuild \
        -I nixpkgs=${nixpkgs} \
        -I nixos-config=${nixos-config} \
        "$@"
    '';

  inherit (import nixos-path {
    configuration = { modulesPath, ... }: {
      imports = [
        (modulesPath + "/virtualisation/qemu-vm.nix")
        ./module
        ./examples/minimal.nix
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
  }) vm;
}

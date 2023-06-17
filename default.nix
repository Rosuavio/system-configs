{ sources ? import ./nix/sources.nix
, nixpkgs ? sources."nixos-23.05"
, ...
}:
let
  nixpkgs-path = nixpkgs;
  nixos-path = nixpkgs-path + "/nixos";

in
{
  inherit nixpkgs;

  mkRebuildScript =
    { nixos-config
    , nixpkgs ? nixpkgs-path
    , pkgs ? import nixpkgs { }
    }:
    pkgs.writeShellScriptBin "nixos-rebuild" ''
      exec /run/current-system/sw/bin/nixos-rebuild \
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
        # NOTE: Blindly copied from
        # https://discourse.nixos.org/t/problem-with-sway-in-nixos-rebuild-build-vm-how-to-configure-vm/20263/3
        qemu.options = [
          "-vga none"
          "-device virtio-vga-gl"
          "-display gtk,gl=on"
        ];
      };
    };
  }) vm;

  pre-commit-check = (import sources."pre-commit-hooks.nix").run {
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
      markdownlint.enable = true;
      typos.enable = true;
    };

    settings = {
      statix.ignore = [ "nix/**" ];
    };
  };
}

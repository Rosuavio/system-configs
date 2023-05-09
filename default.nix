{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, nixos ? nixpkgs + "/nixos"
, pkgs ? import nixpkgs {}
, ...
}:
let
  os = import nixos { configuration = ./test-os.nix; };
in
{
  module = import ./module;
  mkRebuildScript = nixpkgs-path: nixos-config-path:
    pkgs.writeShellScriptBin "nixos-rebuild" ''
        exec ${pkgs.nixos-rebuild}/bin/nixos-rebuild \
          -I nixpkgs=${nixpkgs-path} \
          -I nixos-config=${nixos-config-path} \
          "$@"
      '';
  vm = os.vm;
}

{pkgs, ... }:
{
  module = import ./module;
  mkRebuildScript = nixpkgs-path: nixos-config-path:
    pkgs.writeShellScriptBin "nixos-rebuild" ''
        exec ${pkgs.nixos-rebuild}/bin/nixos-rebuild \
          -I nixpkgs=${nixpkgs-path} \
          -I nixos-config=${nixos-config-path} \
          "$@"
      '';
}

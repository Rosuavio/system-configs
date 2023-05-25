let
  sources = import ./nix/sources.nix;
  pkgs = import sources."nixos-22.11" { };

  default = import ./default.nix { };
in
pkgs.mkShell {
  name = "os-dev";

  packages = [
    pkgs.git
    pkgs.niv
  ];

  shellHook = ''
    ${default.pre-commit-check.shellHook}
    echo 'Welcome to the system development shell!'
  '';

}

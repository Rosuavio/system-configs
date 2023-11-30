let
  sources = import ./npins;
  pkgs = import sources.nixpkgs-unstable { };

  default = import ./default.nix { };
in
pkgs.mkShell {
  name = "os-dev";

  packages = [
    pkgs.git
    pkgs.npins
  ];

  shellHook = ''
    ${default.pre-commit-check.shellHook}
    echo 'Welcome to the system development shell!'
  '';

}

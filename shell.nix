let
  sources = import ./nix/sources.nix;
  inherit (sources) nixpkgs;
  pkgs = import nixpkgs { };

  default = import ./default.nix { inherit pkgs; };

in
pkgs.mkShell {
  name = "os-dev";

  packages = [
    pkgs.git
    pkgs.niv
  ];

  shellHook = ''
    echo 'Welcome to the system development shell!'
    ${default.pre-commit-check.shellHook}
  '';

}

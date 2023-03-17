let
  module = "${builtins.toString ./.}/test-os.nix";

  sources = import ./nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs {};

  default = import ./default.nix { inherit pkgs; };

in pkgs.mkShell {
  name = "os-dev";

  packages = [
    pkgs.git
    pkgs.niv
    (default.mkRebuildScript nixpkgs module)
  ];

  shellHook = ''
    echo 'Welcome to the system development shell!

    1) To rebuild the system run `nixos-rebuild`.'
  '';

}

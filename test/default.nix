let
  sources = import ../nix/sources.nix;
  inherit (sources) nixpkgs;
  pkgs = import nixpkgs { };
  nixos-lib = import (nixpkgs + "/nixos/lib") { };

in
nixos-lib.runTest {
  imports = [
    {
      name = "graphical-login";

      nodes.machine = {
        imports = [
          ../module
          ../default-config.nix
        ];

        # Seems to be good for Ryzen 5 3600
        virtualisation = {
          memorySize = 1024 * 2;
          cores = 6;
        };

        virtualisation.qemu.options = [
          "-vga none"
          "-device virtio-gpu-pci"
        ];

        environment.variables = {
          "WLR_RENDERER" = "pixman";
        };

        ocrOptimiztions = true;
      };

      interactive.nodes.machine = {
        # Need to switch to a different GPU driver than the default one (-vga std) so that Cage can launch:
        virtualisation.qemu.options = [
          "-vga none"
          "-device virtio-vga-gl"
          "-display gtk,gl=on"
        ];
      };

      enableOCR = true;

      testScript = ''
        machine.start()
        machine.wait_for_unit("greetd")
        machine.wait_for_text("Welcome back!")
      '';
    }
  ];

  hostPkgs = pkgs;
}

let
  nixpkgs = (import ../npins)."nixos-23.11";
  pkgs = import nixpkgs { };
  nixos-lib = import (nixpkgs + "/nixos/lib") { };
in
nixos-lib.runTest {
  imports = [
    {
      name = "graphical-login";

      meta.timeout = 900;

      nodes.machine = {
        imports = [
          ../module
          ../examples/minimal.nix
        ];

        # Seems to be good for Ryzen 5 3600
        virtualisation = {
          memorySize = 1024 * 2;
          cores = 6;
        };

        virtualisation.qemu.options = [
          "-vga none"
          "-device virtio-gpu-pci,edid=on,xres=1024,yres=600"
        ];

        environment.variables = {
          "WLR_RENDERER" = "pixman";
        };
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
        machine.wait_for_text("Authenticate into machine")
      '';
    }
  ];

  hostPkgs = pkgs;
}

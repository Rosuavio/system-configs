let
  sources = import ../nix/sources.nix;

  inherit (sources) nixos-hardware;
in
{
  imports =
    [
      "${nixos-hardware}/lenovo/thinkpad/t480"
      "${nixos-hardware}/common/cpu/intel/kaby-lake"
      ./default.nix
    ];

  # TODO: Validate I want the effects of this.
  services.thermald.enable = true;
  services.udisks2.enable = true;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
  };

  networking.hostName = "pulsar";
  networking.hostId = "f696fe6c";
}

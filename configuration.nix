# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  hostName = "pulsar";

  nixos-hardware = builtins.fetchGit "https://github.com/NixOS/nixos-hardware.git";
in
{
  imports =
    [ ./hardware-configuration.nix
      ./users
      "${nixos-hardware}/lenovo/thinkpad/t480"
      "${nixos-hardware}/common/cpu/intel/kaby-lake"
      "${nixos-hardware}/common/pc/laptop/ssd"
    ];

  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  hardware.opengl.enable = true;
  hardware.bluetooth.enable = true;

  security.pam.services.swaylock = {};

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  fonts.enableDefaultFonts = true;

  services = {
    hardware.bolt.enable = true;
    pcscd.enable = true;
    flatpak.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    openssh.enable = true;

    fwupd.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet";
      };
    };
  };

  services.dbus.packages = [ pkgs.gnome.dconf ];

  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.kernelParams = [ "synaptics_intertouch=1" ];

  # TODO 2020.01.24 (RP) - Find a way to change the esp to "/esp"
  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot = {
      enable = true;
      editor = false;
    };

    efi = {
      # efiSysMountPoint = "/boot/efi";
      canTouchEfiVariables = true;
    };

    timeout = null;
  };

  networking.hostName = hostName;
  networking.hostId = "f696fe6c";

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  environment.systemPackages = with pkgs; [
    nix
  ];

  programs.dconf.enable = true;

  i18n.extraLocaleSettings =
  let l = "en_US.UTF-8";
  in {
    LC_CTYPE = l;
    LC_NUMERIC = l;
    LC_TIME = l;
    LC_COLLATE = l;
    LC_MONETARY = l;
    LC_MESSAGES = l;
    LC_PAPER = l;
    LC_NAME = l;
    LC_ADDRESS = l;
    LC_TELEPHONE = l;
    LC_MEASUREMENT = l;
    LC_IDENTIFICATION = l;
  };

  nix.trustedUsers = [ "root" "rosario" ];

  nix.binaryCaches = [ "https://nixcache.reflex-frp.org" ];
  nix.binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];

  system.stateVersion = "21.05";

  system.autoUpgrade.enable = false;
}

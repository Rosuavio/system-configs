# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  hostName = "polaris";

  nixos-hardware = builtins.fetchGit "https://github.com/NixOS/nixos-hardware.git";
in
{
  imports =
    [ ./hardware-configuration.nix
      ./users
      ./obsidian
      "${nixos-hardware}/common/cpu/amd"
      "${nixos-hardware}/common/gpu/amd"
      "${nixos-hardware}/common/pc/ssd"
      "${nixos-hardware}/common/pc"
    ];

  boot.kernelModules = [ "btqca" "btusb" "hci_qca" "hci_uart" "sg" "btintel" ];

  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/e9966ab2-a663-4c04-87d9-1558aa92601d";
    allowDiscards = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  hardware.video.hidpi.enable = true;

  hardware.opengl.enable = true;
  hardware.ledger.enable = true;

  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = false;

  hardware.openrazer = {
    enable = true;
    users = [ "rosario" ];
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  environment.pathsToLink = [ "/share/backgrounds/sway" ];

  xdg.portal = {
    enable = true;
    # gtkUsePortal = true;
    wlr.enable = true;
  };

  fonts.enableDefaultFonts = true;

  services = {
    pcscd.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    openssh.enable = true;

    fwupd.enable = true;

    zfs.autoScrub.enable = true;
  };

  services.greetd = {
    enable = false;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet";
      };
    };
  };

  programs.dconf.enable = true;

  services.dbus.packages = [ pkgs.gnome.dconf ];

  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  # TODO 2020.01.24 (RP) - Find a way to change the esp to "/esp"
  boot.loader = {
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
  networking.hostId = "6a82d7b3";

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  environment.systemPackages = with pkgs; [
    nix
  ];

  i18n.extraLocaleSettings = {
    LC_CTYPE = "en_US.UTF-8";
  };

  nix.trustedUsers = [ "root" ];

  system.stateVersion = "21.11";

  system.autoUpgrade.enable = false;
}

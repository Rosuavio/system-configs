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
    ];

  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  hardware.opengl.enable = true;
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;

  services = {
    hardware.bolt.enable = true;
    pcscd.enable = true;
    pipewire.enable = true;
    throttled.enable = false;
    openssh.enable = true;

    fwupd.enable = true;
  };

  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.zfs.forceImportAll = false;

  boot.kernelParams = [ "elevator=none" ];

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
  ];

  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  programs.sway = {
    enable = false;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
       swaylock
       swayidle
       xwayland
       wl-clipboard
       mako
       alacritty
       rxvt-unicode
       dmenu
    ];
  };

  system.stateVersion = "20.09";

  system.autoUpgrade.enable = false;
}

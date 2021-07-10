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
    openssh.enable = true;

    fwupd.enable = true;
  };

  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

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
    nix
  ];

  system.stateVersion = "21.05";

  system.autoUpgrade.enable = false;
}

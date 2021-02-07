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
      ./users.nix
      ./services.nix
      "${nixos-hardware}/common/cpu/intel/kaby-lake"
      "${nixos-hardware}/common/pc/laptop/ssd"
      "${nixos-hardware}/lenovo/thinkpad/t480s"
    ];

  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  hardware.opengl.enable = true;
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_5_10;

  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/3947050f-9e13-4395-b65b-e265c983d75b";

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
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        mako
        alacritty
        dmenu
      ];
    };
  };

  environment.systemPackages = with pkgs; [
  ];

  system.stateVersion = "20.09";

  system.autoUpgrade.enable = false;
}

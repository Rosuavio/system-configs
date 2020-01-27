# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./users.nix
    ];

  hardware.bluetooth.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  # Allows hardware u3f devices to be used in apps, like the yubikey in ff via chalange response.
  hardware.u2f.enable = true;

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

  boot.plymouth.enable = true;
  boot.initrd.luks.devices = [
    { 
      name = "NixOS";
      device = "/dev/disk/by-uuid/0829deac-97c3-4ff7-91d1-a11de325e882";
      preLVM = true;
    }
  ];

  networking.hostName = "pulsar";
  networking.networkmanager.enable = true;
  
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  services.throttled.enable = true;
  services.fwupd.enable = true;

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver = { 
    enable = true;

    libinput.enable = true;
    wacom.enable = true;
    displayManager = {
      gdm.enable = true;
      # sddm.enable = true;
    };

    desktopManager = {
      xterm.enable = false;
      # xfce.enable = true;
      # mate.enable = true;
      gnome3.enable = true;
      # plasma5.enable = true;
    };
  };  

  users.mutableUsers = false;

  # security.pam.u2f = {
  #    enable = true;
  #    control = "optional";
  #    cue = true;
  # };

  system.stateVersion = "19.09";

  system.autoUpgrade.enable = true;
}

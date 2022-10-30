{ config, pkgs, lib, ... }:
let

  suspend-fix = pkgs.writeShellScriptBin "suspend-fix" ''
      #!/usr/bin/env bash
      isenabled=`cat /proc/acpi/wakeup | grep $1 | grep -o enabled`
      if [ $isenabled == "enabled" ]; then
        echo $1 > /proc/acpi/wakeup
      else
        exit
      fi
    '';

  nixos-hardware = builtins.fetchGit "https://github.com/NixOS/nixos-hardware.git";
in
{
  imports =
    [ ./users
    ];

  nixpkgs.config.allowUnfree = true;

  boot = {
    supportedFilesystems = [ "zfs" ];
    initrd.supportedFilesystems = [ "zfs" ];

    # I am using zfs and the linux kenrel and zfs cant figure out how to hybernate together
    # REMOVE: When https://github.com/NixOS/nixpkgs/pull/171680 is merged
    # If this is removed and nixos is trackering this issue, then if zfs and linux figure things out
    # When nixpkgs updates I will automaticly get my ability to hybernate again.
    kernelParams = [ "nohibernate" ];
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
    };

    ledger.enable = true;

    bluetooth.enable = true;
    pulseaudio.enable = false;

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
    zfs.autoScrub.enable = true;
    pcscd.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    openssh = {
      enable = true;
      gatewayPorts = "clientspecified";
    };

    fwupd.enable = true;
    printing.enable = true;
  };

  services.greetd = {
    enable = false;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet";
      };
    };
  };

  programs = {
    dconf.enable = true;
  };

  services.dbus.packages = [ pkgs.dconf ];

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

  networking.networkmanager.enable = true;

  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  environment.systemPackages = with pkgs; [
    nix
  ];

  i18n.extraLocaleSettings = {
    LC_CTYPE = "en_US.UTF-8";
  };

  time.timeZone = "America/New_York";

  nix.trustedUsers = [ "root" ];

  system.stateVersion = "22.05";

  system.autoUpgrade.enable = false;
}

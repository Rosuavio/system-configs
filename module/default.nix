{ config, options, pkgs, lib, ... }:
let
  cfg = config;
in
{
  options = {
    ocrOptimiztions = lib.mkEnableOption "ocrOptimiztions";
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    boot = {
      supportedFilesystems = [ "zfs" ];
      initrd.supportedFilesystems = [ "zfs" ];

      # Broken: Shows a spinner when asking for encryption password
      # Can still input the password but there is no visual inducation or feedback
      # boot.plymouth.enable = true;
    };

    hardware = {
      enableAllFirmware = true;
      enableRedistributableFirmware = true;
      opengl = {
        enable = true;
        driSupport = true;
      };

      bluetooth.enable = true;
      pulseaudio.enable = false;
    };

    security.polkit.enable = true;
    security.pam.services.swaylock = { };

    security.tpm2 = {
      enable = true;
      tctiEnvironment.enable = true;
    };

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
        settings = {
          GatewayPorts = "clientspecified";
        };
      };

      fwupd.enable = true;
      printing.enable = true;
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

    services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    environment.etc."NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };

    environment.systemPackages = with pkgs; [
      nix
    ] ++ lib.optional cfg.ocrOptimiztions pkgs.inconsolata;

    i18n.extraLocaleSettings = {
      LC_CTYPE = "en_US.UTF-8";
    };

    time.timeZone = "America/New_York";

    nix = {
      nixPath = [ ];
      settings = {

        trusted-users = [
          "root"
          "@wheel"
        ];

        substituters = [
          "https://rosuavio-personal.cachix.org"
        ];

        trusted-public-keys = [
          "rosuavio-personal.cachix.org-1:JE9iWA0eTZbknfGo2CtxMyxpbU7OjDFN4eCqKI7EmdI="
        ];
      };
    };

    users.mutableUsers = false;

    users.users = {
      rosario = {
        description = "Rosario Pulella";
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "video" "adbusers" ];
      };
    };

    services.greetd.enable = true;

    programs.regreet = {
      enable = true;
      settings = lib.mkIf cfg.ocrOptimiztions {
        GTK = {
          font_name = "Inconsolata 16";
          application_prefer_dark_theme = true;
        };
      };
    };

    system.stateVersion = "23.05";

    system.autoUpgrade.enable = false;
  };
}

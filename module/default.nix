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
    ] ++ lib.optional cfg.ocrOptimiztions pkgs.inconsolata;

    i18n.extraLocaleSettings = {
      LC_CTYPE = "en_US.UTF-8";
    };

    time.timeZone = "America/New_York";

    system.disableInstallerTools = true;

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

    services.greetd = {
      enable = true;
      settings.default_session.command =
        let
          greetdConfig = (pkgs.formats.toml { }).generate "regreet-config.toml"
            (lib.optionalAttrs cfg.ocrOptimiztions {
              GTK = {
                font_name = "Inconsolata 16";
                application_prefer_dark_theme = true;
              };
            });

          loginSwayConfig = pkgs.writeText "greetd-sway-config" ''
            # Changing the scale can improve OCR in tests scripts
            # TODO: Make this configuable for the test env
            # output "Virtual-1" scale 1

            # #wlgreet is currently broken on 22.11, its version does not find wayland libs
            # would like to use it when possible
            # https://github.com/NixOS/nixpkgs/pull/210464#issuecomment-1437583852
            exec "${lib.getExe pkgs.greetd.regreet} --config ${greetdConfig}; swaymsg exit"

            # TODO: This does not seem to be working, invesitage
            bindsym Mod4+shift+e exec swaynag \
              -t warning \
              -m 'What do you want to do?' \
              -b 'Poweroff' 'systemctl poweroff' \
              -b 'Reboot' 'systemctl reboot'

            # This is a fix for long load times, invesitage
            # ref: https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start
            # ref: https://github.com/swaywm/sway/issues/5732
            # TODO: Test it
            exec "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP"
          '';
        in
        "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.sway} --config ${loginSwayConfig}";
    };

    system.stateVersion = "22.11";

    system.autoUpgrade.enable = false;
  };
}

{ config, pkgs, lib, ... }:
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

  nix.settings = {
    substituters = [ "https://nixcache.reflex-frp.org" ];
    trusted-public-keys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];
  };

  services.greetd = {
    enable = true;
    settings.default_session.command = let
      login_sway_config = pkgs.writeText "greetd-sway-config" ''
        exec "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP"

        bindsym Mod4+shift+e exec swaynag \
          -t warning \
          -m 'What do you want to do?' \
          -b 'Poweroff' 'systemctl poweroff' \
          -b 'Reboot' 'systemctl reboot'

        # #wlgreet is currently borken on 22.11, its version does not find wayland libs
        # would like to use it when posible
        # https://github.com/NixOS/nixpkgs/pull/210464#issuecomment-1437583852
        exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
      '';
    in "${pkgs.sway}/bin/sway --config ${login_sway_config}";
  };

  system.stateVersion = "22.11";

  system.autoUpgrade.enable = false;
}

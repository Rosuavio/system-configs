{ config, options, pkgs, lib, ... }:
let
  cfg = config;

  sources = import ../nix/sources.nix;
  lanzaboote = import sources.lanzaboote;

  inherit (sources) impermanence;
in
{
  imports = [
    lanzaboote.nixosModules.lanzaboote
    "${impermanence}/nixos.nix"
  ];

  options = {
    ocrOptimiztions = lib.mkEnableOption "ocrOptimiztions";
  };

  config = {
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot/";
    };

    fileSystems."/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        # For some reason setting this to 2G kept lanzaboote from building
        # Something about /tmp not having space, but I thought /tmp is on its
        # own tmpfs and defaults to 50%.
        "size=4G"
        "mode=755"
      ];
    };

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

    environment.persistence."/persist" = {
      directories = [
        # Connections added dynamically by network manager.
        "/etc/NetworkManager/system-connections"

        "/etc/secureboot"

        # TODO: Should this be like this?
        # Maybe we store this with the other users somehow.
        # Maybe we dont persist this at all.
        # Maybe treating this a system directory like /var or /etc/ is best.
        "/root"

        # I don't think its worth persisting this, not needed either.
        # TODO: Play with it/invesitage
        # https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s05.html
        # "/var/cache"

        # So that users don't get sudo lecture the first time they sudo for each
        # boot.
        # This should default to persist when sudo is enabled
        # TODO: Invesitage /var/db/, it seems fairly uncommon so we should not
        # need the whole thing.
        "/var/db/sudo"

        # Expected persistent state many programs
        # TODO: maybe only persist certain directories for whats enabled on the
        # system.
        # https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s08.html
        "/var/lib"

        # System logs
        # https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s10.html
        "/var/log"

        # Cups uses this as its print spool /var/spool/cups/
        # Any user program can make a directory in here.
        # https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s14.html
        "/var/spool"

        # Place for system and users to put temporary files that should be
        # persisted.
        # https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s15.html
        "/var/tmp"
      ];

      files = [
        # Adjustment value from system clock to os clock or something
        "/etc/adjtime"

        # Managed by `users`
        # Its hard to pick apart and hard and fast rules from
        # nixos/modules/config/update-users-groups.pl, but what seems clear is
        # This files can have state, if they are discarded on reboot so is the state
        # (like user passwords). But not all of the contents of the files are
        # statefull, declarative users will always be resored by the activation
        # scripts. If mutiable users is true, users created manually will end up in
        # these files.
        # TODO: If mutableUsers, default persist else default no-persist,
        # overridable either way.
        # "/etc/group"
        # "/etc/passwd"
        # "/etc/shadow"
        # "/etc/subgid"
        # "/etc/subuid"

        # Unique identifier for the machine
        # In some systems you would want a new one of this for every boot
        # Not in mine, as mine should not look stateless.
        # This is considered confidential, but it is readable by anyone on the system.
        # (including othets)
        # This does need seem like it need to be writable.
        "/etc/machine-id"

        # Single source of truth on what pools need/can? be imported automatically
        # at boot other than any pools needed for boot (because the bootloader
        # will load those).
        # https://github.com/openzfs/zfs/issues/2433#issuecomment-47436580
        # https://openzfs.github.io/openzfs-docs/Project%20and%20Community/FAQ.html#the-etc-zfs-zpool-cache-file
        # I dont have non-boot zpools, no need to persist.
        # "/etc/zfs/zpool.cache"

        # I don't really think I should have to persist anything in /var/cache/
        # but regeet is storing state in there.
        # TODO: This is reconfiguable so I should just reconfigure my instance.
        # Maybe the default will change with
        # https://github.com/rharish101/ReGreet/issues/33
        "/var/cache/regreet/cache.toml"
      ]
      # `config.services.openssh.hostKeys` is used to spcify keys present on
      # the system. The sshd config will point to them. If they do not exist
      # they will be generated before sshd is started. We want to pressist them
      # to avoid the machine generating new ssh keys on every boot.
      ++ lib.concatMap
        (key: [ key.path (key.path + ".pub") ])
        config.services.openssh.hostKeys;
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
      efi = {
        # efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };

      timeout = null;
    };

    boot.initrd.systemd.enable = true;

    networking.networkmanager.enable = true;

    services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
      };
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

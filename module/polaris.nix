{ config, pkgs, lib, ... }:
let
  sources = import ../nix/sources.nix;

  hostName = "polaris";

  inherit (sources) nixos-hardware impermanence;
in
{
  imports =
    [
      "${impermanence}/nixos.nix"
      "${nixos-hardware}/common/cpu/amd"
      "${nixos-hardware}/common/cpu/amd/pstate.nix"
      "${nixos-hardware}/common/gpu/amd"
      "${nixos-hardware}/common/pc/ssd"
      "${nixos-hardware}/common/pc"
      "${nixos-hardware}/common/hidpi.nix"
      ./default.nix
    ];

  boot.kernelModules = [ "kvm-amd" "btqca" "btusb" "hci_qca" "hci_uart" "sg" "btintel" ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];

  fileSystems."/" =
    {
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

  fileSystems."/nix" =
    {
      device = "mainpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "mainpool/safe/home";
      fsType = "zfs";
    };

  fileSystems."/persist" =
    {
      device = "mainpool/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/7825-1D31";
      fsType = "vfat";
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


  boot.plymouth.enable = true;
  boot.zfs.forceImportRoot = false;

  hardware = {
    openrazer = {
      enable = true;
      users = [ "rosario" ];
    };
  };

  systemd.services = {
    # Maybe try to figure out whats going on with this device. Try a bios update.
    # B550I-AORUS-PRO-AX
    suspend-fix = {
      enable = true;

      wants = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Description = "Disable GPP0 to fix suspend issue";
        Type = "simple";
        ExecStart =
          "${pkgs.bashInteractive}/bin/sh -c \"${pkgs.coreutils}/bin/echo GPP0 > /proc/acpi/wakeup\"";
      };
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
    fuse3
    sbctl
  ];

  users.users = {
    rosario = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDrofEHtfNnlLRqi2zb5XmJOvXPlm6eU6XK5YhTgFnB rosario@pulsar"
      ];
    };
  };

  networking.hostName = hostName;
  networking.hostId = "6a82d7b3";
}

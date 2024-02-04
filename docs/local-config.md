# Local config

My systems always have some portion of config that is local-only. There are
various techniques and tools we can use for managing the local system config.

## Current Solution

Combine [user owned cofing](#user-owned-config), a
[local wrapper](#local-wrapper) and
[un-setting `nixos-config`](#un-set-nixos-config). With this combination we get
the benefits of all those solutions only losing out on some of the benefits of
the [default cofing location](#default-config-location).

Good

1. Dose not require `sudo` to edit.
2. No need for user to remember parameter or config.
3. Users cannot build the default config unintentionally.

Bad

1. Hard or impossible for other users to find.
2. Hard or impossible for other users to read.
3. Could be impossible users with `nixos-rebuild switch` to edit.
4. Pushes users with `nixos-rebuild switch` to maintain separate configs for the
system. Possibly fighting over what config to run.
5. If the user forgets to enter the shell they get none of the benefits of the
context of the local project.

## Solutions

### Default config location

When first installing NixOS, the system configuration is placed in
`/etc/nixos/configuration.nix`, and the `nixos-rebuild` command looks there by
default for the nixos configuration to build the systems off of.

Good

1. Easy for all users to find.
2. Easy for all users to read.
3. Anyone with permissions to `nixos-rebuild switch` can edit.
4. Requires that no extra users are already setup.

Bad

1. Requires `sudo` to edit.

### User owned config

The system config files can be kept in a user's directory, where they own the
entire directory.

Good

1. Does not require `sudo` to edit.

Bad

1. Hard or impossible for other users to find.
2. Hard or impossible for other users to read.
3. Could be impossible users with `nixos-rebuild switch` to edit.
4. Pushes users with `nixos-rebuild switch` to maintain separate configs for the
system. Possibly fighting over what config to run.
5. Requires extra config for `NIX_PATH` or remembering
`-I nixos-config=./foo.nix` with every call to `nixos-rebuild`. This can lead
to a user unintentional building config from the default directly.

### Local wrapper

We can provide a `shell.nix` file in the local repo with the nix system config
that provides a version of `nixos-rebuild` that wraps the `nixos-rebuild`
command with the `-I nixos-config=./configuration.nix` option.

Good

1. No need to remember parameter or config, because tools are configured in a way
that is sensitive to the context of the local project.

Bad

1. If the user forgets to enter the shell they get none of the benefits of the
context of the local project.

### Un-set `nixos-config`

Un-set `nixos-config` system wide.

Good

1. Users cannot build the default config unintentionally.

Bad

1. User's must always provide the config they want to build to `nixos-rebuild`
(even when its apparent)

## Other Solutions

### System provides wrapped `nixos-rebuild`

We might be able to wrap `nixos-rebuild` so that when a build is used for the
system (like with the `boot` `switch` sub commands), the local directory is
linked to `/etc/nixos/` (or something like that).

Good

1. Can build config from anywhere given the right permissions.
2. Anyone can see the current system config.

Bad

1. More complex

### System provides GitHub pull request like workflow

Users with perms can push directly and everyone can see it. Users without perms
can request changes/config is pulled.

Good

1. Give non admin users way to change system
2. Don't have to give everyone admin

Bad

1. Way complex

### Provide system installer and recovery tool that aligns with desired config

Any deviation from the standard config means that when I use the stock nixos
installer to install nixos or recover a system it I will have to try to bring
the config back inline with how I want it. Providiing tools like installer
images, recovery tools and local config templates could help me deal with that.
Such tooling needs to be tested.

### Provide tools to enable solutions in local repositories

Providing a template repo and some tools that help augment local config's nix
shells and build could help too.

## NOTES

Can build config anywhere
`nixos-rebuild` can be told to use a different path than the default to find
the default config. This is done by setting the `NIX_PATH` variable
`nixos-config` to another location. The `NIX_PATH` can be manipulated by
prepending a variable+value pair to the environment variable combined by an `=`
and separated from other variables with a `:`.
(ex. `NIX_PATH="nixos-config=/home/username/config.nix:${NIX_PATH}"`) or by
running the a nix command with the `-I` flag
(ex. `nixos-rebuild boot -I nixos-config=/home/username/config.nix`).

"Provide usability tools - Make managing my NixOS configs on my machines easier.
So far this only includes my `nixos-rebuild` wrapper, but I plan on adding tools
to make it easier to tests system-specific configs not in this repo while on my
systems."

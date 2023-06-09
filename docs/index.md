# System configurations

The main purpose of this repository is to provide a central location for the
common configurations I typically apply to my systems. Though I do not keep all
of my configurations in this common location
see [Common vs Local Configuration](common-vs-local-config.md).

Given that a lot of my common configurations live here I felt like it made sense
to have some level of testing of my configurations so I can quickly iterate on
my configurations and easily test my configurations against the latest changes
in Nixpkgs. See [Testing](testing.md).

Testing my configurations would require building and running virtual systems
based on the common configurations. Given that that work for building
my configurations was already being done, the builds are cached for my systems
to use to avoid rebuilding. See [Caching](caching.md).

This repository also provides some tools for managing local configurations. See
[Local Configuration](local-config.md).

## Thoughts

So, in deviating from the standard NixOS config I might introduce issues into
my system threw untested paths.

### nixos-rebuild versions

One of this such paths is how my systems are build and what version of tools are
used when.

#### De-facto

So in the typical nixos system, the currently running system provided
`nixos-rebuild` and that system was built the last time `nixos-rebuild` was
used to rebuild the system. So if the `<nixpkgs>` is updated and then the
system is updated then the system is built using a `nixos-rebuild` from the
previous build but using the next `<nixpkgs>`. This means system being switched
into could have a very different `nixos-rebuild`.

This is the standard practice and thus most tested/used.

#### Using only one nixpkgs

So if we used only one version for `nixos-rebuild` and the `nixpkgs` used to
build the next system then we will not use the current system's `nixos-rebuild`
to build the next system. Instead we will be using the next system's
`nixos-rebuild` to build the next system.

#### In-project moving build emulation

I local repos we can have the development shell use a separately pinned `nixpkgs`
than the `nixpkgs` for the next build. The local shell will get its
`nixos-rebuild` from the the pinned nixpkgs (falling back to another nixpkgs if
its not available, maybe the next `nixpkgs`). Then `nixos-rebuild` and be
wrapped to take whatever nixpkgs was used to update the pin **after**
`nixos-rebuild` builds a new system.

Problems

1. Can easily get completely out of sync with the currently running system and
being in sync with it is the point. ):

#### Use system `nixos-rebuild`

Instead of using `nixos-rebuild` from next `nixpkgs`, use the `nixos-rebuild`
from the currently running system.

Problems

1. Forces my systems to pin nixos-rebuild, maybe I am building a system that
does not get built remotely or something.
2. `nixos-rebuild` is not needed in normal usage of system.

#### Use currently running system's `nixpkgs`

Have the system provide a nixpkgs locally and use it to build `nixos-rebuild` is
system dev shell.

Problems

1. Pins a copy of nixpkgs, keeping it from being able to be gc'ed

#### Use currently running system's `nixpkgs` pin

Have the system provide all the information to purely retrieve the `nixpkgs`
used to build it's self.

Problems

1. Does not pin a copy of nixpkgs, meaning that a gc can cause the user to not
be able to change the system config when they don't have access to the source for
for `nixpkgs`.

#### On build put next nixos-rebuild in system (/run/current-system/)

When the system is built we put `nixos-rebuild` in the next system's
`/run/current-system/` by using `system.extraDependencies` and don't include it
in system packages with `system.disableInstallerTools = true`. When the build
shell can wrap the mutable path `/run/current-system/bin/nixos-rebuild`

This is good because it does not pin the `nixpkgs` that built it, but it also
does not add to the list of things that need to be downloaded to change the
config.

##### Useful

system.includeBuildDependencies
system.copySystemConfiguration

system.extraDependencies

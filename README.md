Personal system configs and supporting infra.

# Why?
Just having a repo with bunch of NixOS modules is not easy enough to reliably
share across machines, run and deploy updates and maintain the same guaranties
nixos typically provides.

So this repo is meant to help with these issues in several ways.
1. Building and caching configurations - By building with GitHub actions and
caching my configurations on Cachix, I avoid having to build many of the
derivations on my machines that use this common configuration.
2. Testing - While nixpkgs has many tests for all the components within here I
can write tests that are more high-level and direct to my use-cases. Also this
serve as a good staging area for any tests that could be worth up-steaming.
3. Automation - I plan to automate, or at least make very simple, the process
of retrieving updates from dependencies(like nixpkgs), running my tests against
those updates and merging the updates if or once they pass tests.
4. Provide usability tools - Make managing my NixOS configs on my machines
easier. So far this only includes my `nixos-rebuild` wrapper, but I plan on
adding tools to make it easier to tests system-specific configs not in this repo
while on my systems.

# Usage
To use the modules import `./module/`

> NOTE: You can use this repo as a derivation using niv, nix-thunk and the like.

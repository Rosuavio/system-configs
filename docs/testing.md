# Testing

With local only configs testing is trivial. When local config files are changed
or dependencies (like nixpkgs, or nixos-hardware) a user can simpily rebuild and
try the system. If there is any errors they can easily boot an eariler config
and revert there changes. This gives the user quick and focued feedback on what
changes caused issues.

When we split out the common config to its own repo this presents some
challenges to testing. Because the common config becomes a dependency of the
local config, locally a user can only test if there local config works with
there dependencies, but there dependencies can not work with eachother. So if a
user updates to a new common config and it has an issues with the latest nixpkgs
they could mistake any issues in the system they build as comming from an
incompatablity between there local config and the common config, where it could
actually come from an incompatablity between the common config and nixpkgs.

Issues

1. Unclear what nixpkgs does the common configs work with.
2. Unclear what nixpkgs to use.
3. Issues in common will not discovered until built localy.
4. When nixpkgs update breaks common it is not discovered until built localy.
5. Difficult to ensure common is used with particual version of nixpkgs.

## Solutions

### Test common with spesific nixpkgs

Build tests against common conifg with a particual nixpkgs using sample local
conifgs, for functionaliy that I want to allways work on my machines.

Good

1. Can use test to validate certain functionaliy works with a common+nixpkgs
combination.

Bad

1. Have to manually run tests against a (common+nixpkgs) pair.
2. Hard to know common+nixpkgs have been validated.
3. Changing a validated common can result in a version that has not been
validated against any nixpkgs.
4. When a newer nixpkgs is published local configs can use those versions even
when common is not validated against it.

### Main always pass tests

Require that main branch of common always passes tests against a version of
nixpkgs tacked in the repo. Keep a version of nixpkgs tacked in the repo and
make it easy to run tests with that version of nixpkgs.

Good

1. Main is always validated against a nixpkgs.
2. Easy to know which common+nixpkgs have been validated.

Bad

1. Have to manually run test before merging to main.

### Test new versions of a nixpkgs channel/branch

Instead of just testing with just one version of nixpkgs, track a channel/branch
of nixpkgs and when there is a new version of nixpkgs published to the
channel/branch open a new PR against main replacing the version of nixpkgs for
testing with latest version for that channel/branch of nixpkgs. Automaticly
merge the PR if it passes all the tests.

Good

1. Know as soon as new nixpkgs breaks tests
2. Automaticly keeps track of latest nixpkgs that pass tests

Bad

1. Pushes into a "can only use if you use with this nixpkgs"

### Automaticly test PRs to main

Main is only changed with a PR and all PR to main get tested automatically.

Good

1. Changes to common are tested promptly
2. Easy to identify issues from common changes

### Provide easy way to use same nixpkgs pin for local configs

Provid easy way to use always use the latest versions of nixpkgs that passed
tests with common, when build local system.

Good

1. Can easily use a common+nixpkgs pair that is tested.

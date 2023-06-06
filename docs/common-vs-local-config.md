# Common vs local config

On my systems I prefer to build to run updates and rebuild my system locally.
This means that changes are always end up being deployed threw a `nixos-rebuild`
on machine locally. That being the case it means I can easily have the
configuration for each machine locally on the machine if I want. At the sametime
many of my machines repeat the same bits of configuration that I like to have
across  multiple if not all of my machines. Such common config can live
somewhere all my machines can easily access it to pull it down for used in local
builds.

## Current Solution

Keep some config a common location (this repo) and some locally on each machine.

To avoid repeating code any config should be in the common location if it meets
these conditions.

1. Possibly useful for multiple machines.
2. Does not contain any plain text (and maybe even encrypted) secrets.

### Local conifg

Benefits

1. Easy to itterate, build and test on a particular machine.
2. No secrets intrinsicly leave the machine.

### Common config

Benefits

1. Easily reuse across machines.
2. Easily share with others.
3. Easily get changes and feedback.
4. Offsite backup.

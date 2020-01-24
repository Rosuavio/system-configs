# What is This?

The NixOS configuration files for my laptop.

# Instructions for myself

## Want to make changes?
1. Changed a file
2. Run `nixos-rebuild switch`

## Want to track changes?
Slightly non-standard way of using git, but it uses "Bare" repos. [ref](https://www.youtube.com/watch?v=tBoLDpTWVOM&t=729s)

Use `git --git-dir=path/to/repo.git --work-tree=/etc/nixos/` instead of just `git` when doing git actions.

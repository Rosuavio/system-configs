# Chaching

## Allways build locally

No matter the system, build configs for local system and only use them locally

Good

1. Do not need to rely on extra infra.
2. Simply build what you need when you need it.

Bad

1. Some config could be usefull for other machines and will be have to build
again.

## Push local builds to cache

After building locally we push the results to accesible cache.

Good

1. Shares build outputs avoid rebuilding same derivations.

Bad

1. Local configs could have sensitive derivations and this would risk pushing
them over the internet to a posibly vurnably or overly accesible location,

## Push common builds to cache

When common builds or nixpkgs is udpated push common builds with nixpkgs using
sample config to cache.

Good

1. Pushes most of what will be shared between systems.
2. Work is done before needed for systems.
3. No sensitive derivations at rist of being exposed.
4. Need to do the work for testing anyways.

Bad

??

# Caching

## Always build locally

No matter the system, build config for local system and only use them locally.

Good

1. Do not need to rely on extra infra.
2. Simply build what you need when you need it.

Bad

1. Some config could be useful for other machines and will be have to built
again.

## Push local builds to cache

After building locally we push the results to accessible cache.

Good

1. Shares build outputs avoid rebuilding same derivations.

Bad

1. Local config could have sensitive derivations and this would risk pushing
them over the internet to a possibly vulnerable or overly accessible location,

## Push common builds to cache

When common builds or nixpkgs is updated push common builds with nixpkgs using
sample config to cache.

Good

1. Pushes most of what will be shared between systems.
2. Work is done before needed for systems.
3. No sensitive derivations at risk of being exposed.
4. Need to do the work for testing anyways.

Bad

??

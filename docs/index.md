# System configs

The main purpouse of this repository is to provide a cental location for the
common configurations I typically apply to my systmes. Though I do not keep all
of my configurations in this common location
see [Common vs Local config](common-vs-local-config.md).

Given that alot of my common configurations live here I felt like it made sense
to have some level of testing of my configurations so I can quickly ittrate on
my configurations and easily test my configurations aginst the latests changes
in nixpkgs. See [Testing](testing.md).

Testing my configurations would require building and runing virtual systems
based on the common configurations. Given that that work for building
my configurations was already being done, the builds are cached for my systems
to use to avoid rebuilding. See [Caching](caching.md).

This repo also provides some tools for manageing local configurations. See
[Local Config](local-config.md).

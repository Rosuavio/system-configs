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

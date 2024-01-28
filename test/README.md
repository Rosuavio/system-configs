# Testing

## Motivation

TODO

## Improving testability

Some ideas...

1. Bootup and various processes take a lot of time. Perhaps the state of the VM
can be saved and tests can reuse and branch off of tested states to speed up
tests as the amount of tests grow.
2. There is a hierarchy for optimally strategies for making things
"more testsable".
    1. No change - Avoid having to run any special changes in tests to have the
    tests best reflect what it will be like to use the environment.
    2. Test environment - The test environment can be changed to make things easier
    to test (like virtual configuration of the VM emulating a machine running the
    software). This is not so bad because the software is expected to run on
    various physical configurations, and while changing settings to improve
    "testability" does not necessarily reflect realistic physical configurations, it
    does modulate settings in a space where settings are expected to be modulated.
    Some examples are display count and resolutions, memory, cpu, graphical and
    storage resources.
    3. Test subject - Specific changes to the configuration of the software being
    tested can be made to make the software more testable. This is not preferable
    because it changes the actually software that will be use in a way that could
    not be useful in real use cases adding unneeded variables while also its use
    in tests means that more relist configurations are not being tested. This
    could necessary to make something tesitable that would be difficult or
    impossible otherwise.
    One example is that to improve the performance of OCR tools that analyses the
    software from an external perspective, a change to the UI settings of the
    software being tested can make a big impact; like contrast, UI scale, font
    and font size.

The reality that we might need to modify the test subject to improve testability,
means that we might need to add do things to make the things being tested more
configurable to enable tests.

## Things that can help with OCR

### Colors and contrast

Different combinations of front colors and background colors can
dramatically effect the performance of OCR

This dose not seem easily do-able from the VM/test environment level.
This might be something that can be done in a display server/wayland
compositor.
I had success configuring regreet with
Regreet
'GTK.application_prefer_dark_theme = true;'
regreet can be totally customized in appearance which is very helpful.

### Front

The font can sometimes be changed globally and certain fonts are designed
to be easier for OCR to recognize.

Controlling the font is not feasible threw the VM/test environment.
I can change what fronts are available to the OS globally and I might even
be able to change **some** global defaults for fonts, but its is very
possible that some apps will ignore such defaults or use a mix of fonts,
this global config is unreliable.
I had success configuring regreet with
Global
fonts.fonts = [ pkgs.inconsolata ];
Regreet
'GTK.font_name = "Inconsolata 16';

### Font Size

Increasing the font sizes to 16-32 ish can improve OCR a lot
This usually needed to be configured on a per app basis

Controls much like the font section.

### Playing with font rendering options

Can make a difference in the text it effects

Similar control story to the #Font section
fonts.fontconfig = {
  antialias = false;
  hinting.enable = false;
  subpixel.lcdfilter = "none";
};

### Resolution

Inconsistent in efficacy, but should be high enough. (The default seems fine)

Can easily be configured from the VM.
virtualisation.qemu.options = [ -device fooo,xres=XXX,yres=YYY ]

### UI Scaling

Usually threw whatever window manager or DE like thing
In creasing the resolution usually dose not cause the UI to scale,
and leave the UI elements as really small, but if the UI is scaled
up with the resolution it gives more pixels for each character which
can improve OCR

Something best configured in display manager/compositor, and its a common
feature to for those tools to want to provide.

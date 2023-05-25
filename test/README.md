# Testing

## Motivation

TODO

## Improving testablity

Some ideas...

1. Bootup and various processes take a lot of time. Perhaps the state of the VM
can be saved and tests can reuse and branch off of tested states to speed up
tests as the amount of tests grow.
2. There is a hireachy for optimaly strategies for making things
"more testsable".
    1. No change - Avoid having to run any special changes in tests to have the
    tests best refelect what it will be like to use the environment.
    2. Test environment - The test environment can be changed to make things esier
    to test (like virtual configuration of the VM emulating a mechine running the
    software). This is not so bad because the software is expected to run on
    various phisical configurations, and while changing settings to improve
    "testablity" does not neccisrarly reflect relisct phisical configurations, it
    does modulate settings in a space where settings are ecpected to be modulated.
    Some examples are display count and resolutions, memory, cpu, graphical and
    storage resoruces.
    3. Test subject - Specific changes to the configuration of the software being
    tested can be made to make the software more testable. This is not preferable
    becuase it changes the actually software that will be use in a way that could
    not be usefull in real usecases adding unneeded variables while also its use
    in tests means that more relist configurations are not being tested. This
    could neccisary to make something tesitable that would be difficult or
    imposible otherwise.
    One exmaple is that to improve the preformace of OCR tools that anazlise the
    software from an external perspective, a change to the UI settings of the
    software being tested can make a big impact; like contrast, UI scale, font
    and font size.

The reality that we might need to modify the test subject to improve testablity,
means that we might need to add do things to make the things being tested more
configurable to enable tests.

## Things that can help with ocr

### Colors and contrast

Different combinations of front colors and background colors can
dramaticly effect the preformance of OCR

This dose not seem easily do-able from the VM/test environment level.
This might be something that can be done in a display server/wayland
compositer.
I had succes configureing regreet with
Regreet
'GTK.application_prefer_dark_theme = true;'
regreet can be totally customsied in apperance which is very helpfull.

### Front

The font can sometimes be changed globally and certain fonts are desiged
to be easier for OCR to recgonise.

Controling the font is not fesiable thre the VM/test environment.
I can change what fronts are avaible to the OS globally and I might even
be able to change **some** global defaults for fonts, but its is very
posible that some apps will ignore such defaults or use a mix of fonts,
this global config is unreliable.
I had succes configureing regreet with
Global
fonts.fonts = [ pkgs.inconsolata ];
Regreet
'GTK.font_name = "Inconsolata 16';

### Font Size

Increasting the font sizes to 16-32 ish can improve ocr a lot
This ushally needed to be configured on a per app basis

Contorls much like the font section.

### Playing with font rendering options

Can make a diffrence in the text it effects

Similar control story to the #Font section
fonts.fontconfig = {
  antialias = false;
  hinting.enable = false;
  subpixel.lcdfilter = "none";
};

### Resolution

Inconsitant in efficacy, but should be hight enough. (The default seems fine)

Can easily be configured from the VM.
virtualisation.qemu.options = [ -device fooo,xres=XXX,yres=YYY ]

### UI Scalling

Ushally threw whatever window manager or de like thing
In creasing the resolution ushally dose not cause the UI to scale,
and leave the UI elements as really small, but if the UI is scalled
up with the resolution it gives more pixels for each charciter which
can improve OCR

Something best configured in display manager/compositor, and its a common
feature to for those tools to want to provide.

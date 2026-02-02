# Tinted color schemes for Matlab

Over 250 [Tinted Theming](https://github.com/tinted-theming/home) color schemes
for Matlab. Compatible with all Matlab versions starting with R2018a.

Have a look at
[Tinted Gallery](https://tinted-theming.github.io/tinted-gallery/) for examples.

## Applying color schemes

The scheme files in the `schemes/` folder can be applied in Matlab using
the included `tinted_import` function:

- `tinted_import()` with no input will prompt the user to locate the
color theme source file via the GUI.

- `tinted_import(FILENAME)` imports the color scheme options given in
the file FILENAME.


## FAQ

### What is the difference with [matlab-schemer](https://github.com/scottclowe/matlab-schemer)?

- Matlab-schemer has not been updated since 2019 and does not work with the "New Desktop" introduced in
Matlab R2025a (R2024a as an optional beta).

- The color scheme file format is not compatible with matlab-schemer. The color schemes are defined
in JSON files and colors are defined in `[R, G, B]` format, which is a bit more friendly than the
32-bit integer color format used in matlab-schemer .prf files.

- Way more included color schemes.

### What is the difference with ["MATLAB Color Theme Extensions"](https://www.mathworks.com/matlabcentral/fileexchange/181402-matlab-color-theme-extensions)

The Mathworks have also released their own color-theming script, which I was not aware of when
tinted-matlab was started. It also uses a very similar JSON scheme format. Still, tinted-matlab:

- Is fully open-source, so you can modify the theming logic if you want to. Color Scheme Extensions
only includes binary .p files.

- Supports more Matlab versions (R2018a and above). Color Scheme Extensions works only with R2025a
and above.

- Provides way more color schemes.

### Can I define my own color scheme?

Sure! Grab any of the .json scheme files and change the color values in `[R, G, B]` (0-255) format.

You may also submit your scheme to [Tinted project's central schemes repository](https://github.com/tinted-theming/schemes). If accepted, it will automatically be included in this repository and [all other schemes repositories for other applications](https://github.com/tinted-theming/schemes). Read Tinted's [styling guidelines](https://github.com/tinted-theming/base24/blob/main/styling.md) and define your scheme based on the [YAML schema](https://github.com/tinted-theming/base24/blob/main/file.md). 

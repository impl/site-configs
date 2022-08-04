# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, lib, ... }: with lib;
let
  maxComponent = 255;

  clamp = max: v: if v < 0 then 0 else if v > max then max else v;
  clampComponent = clamp maxComponent;
in
{
  # Full transparency.
  transparent = 0;

  # Full opacity.
  opaque = maxComponent;

  # Tests whether the given value has an alpha channel.
  hasAlpha = rgba: rgba.alpha != self.colors.opaque;

  # Converts a channel value from a float between 0 and 1 to our byte scale.
  floatToComponent = f: clampComponent ((self.math.toFloat f) * maxComponent);

  # Converts a channel value from our byte scale to a float between 0 and 1.
  componentToFloat = v: clamp 1.0 ((self.math.toFloat v) / maxComponent);

  # Applies a function to the float value of a channel.
  applyComponentAsFloat = f: v: self.colors.floatToComponent (f (self.colors.componentToFloat v));

  # Converts a channel value from a percentage to our byte scale.
  pctToComponent = pct: floatToComponent (pct / 100.0);

  # Converts a channel value from our byte scale to a percentage.
  componentToPct = v: (componentToFloat v) * 100.0;

  # Create a color from RGB channel values with an alpha channel, where the
  # alpha channel is specified as an integer between 0 and 255.
  rgba = alpha: red: green: blue: {
    alpha = clampComponent alpha;
    red = clampComponent red;
    green = clampComponent green;
    blue = clampComponent blue;
  };

  # Create a fully opaque color.
  rgb = self.colors.rgba maxComponent;

  # Create a color from its RGB(A) hex value, with an optional preceding hash.
  # The alpha channel appears at the beginning, if specified at all.
  hex = s:
    let
      s' = removePrefix "#" s;
      l = builtins.stringLength s';

      parse = n: self.encoding.hexToInt (builtins.substring (n * 2) 2 s');
      get = n:
        if l == 8 then parse n
        else if n == 0 then self.colors.opaque
        else parse (n - 1);
    in
      assert assertMsg (l == 6 || l == 8) "hex: string must have exactly 6 or 8 characters following optional '#'";
      self.colors.rgba (get 0) (get 1) (get 2) (get 3);

  # Create a color from its RGBA hex value, but the hex value is CSS/HTML-style
  # with the alpha channel at the end, if specified at all.
  colorCode = s:
    let
      s' = removePrefix "#" s;
      l = builtins.stringLength s';

      parseDup = n: let int = self.encoding.hexToInt (builtins.substring n 1 s'); in int * 16 + int;
      parseFull = n: self.encoding.hexToInt (builtins.substring (n * 2) 2 s');
      parse = if l == 3 || l == 4 then parseDup else parseFull;

      get = n:
        if l == 4 || l == 8 || n != 3 then parse n
        else self.colors.opaque;
    in
      assert assertMsg (l == 3 || l == 4 || l == 6 || l == 8) "hex: string must have exactly 3, 4, 6, or 8 characters following optional '#'";
      self.colors.rgba (get 3) (get 0) (get 1) (get 2);

  # Set a particular channel for an RGBA attset.
  updateChannel = channel: value: rgba: rgba // { ${channel} = clampComponent value; };

  # Set the alpha channel for an RGBA attrset.
  updateAlpha = self.colors.updateChannel "alpha";

  # Set the red channel for an RGBA attrset.
  updateRed = self.colors.updateChannel "red";

  # Set the green channel for an RGBA attrset.
  updateGreen = self.colors.updateChannel "green";

  # Set the blue channel for an RGBA attrset.
  updateBlue = self.colors.updateChannel "blue";

  # Update all color channels for an RGBA attrset using the given function.
  applyRGB = f: rgba:
    foldl (acc: channel: self.colors.updateChannel channel (f acc.${channel}) acc) rgba [ "red" "green" "blue" ];

  # Scale a particular channel for an RGBA attrset by a percentage difference
  # between -100 (to the minimum) and 100 (to the maximum).
  scaleChannel = channel: pct: rgba:
    let
      current = rgba.${channel};
      value =
        if pct < 0 then current * (1 + pct / 100.0)
        else current + (maxComponent - current) * (pct / 100.0);
    in self.colors.updateChannel channel value rgba;

  # Scale the alpha channel for an RGBA attrset.
  scaleAlpha = self.colors.scaleChannel "alpha";

  # Scale the red channel for an RGBA attrset.
  scaleRed = self.colors.scaleChannel "red";

  # Scale the green channel for an RGBA attrset.
  scaleGreen = self.colors.scaleChannel "green";

  # Scale the blue channel for an RGBA attrset.
  scaleBlue = self.colors.scaleChannel "blue";

  # Scale red, green, and blue channels by a given percentage. This is darkening
  # or lightening by a relative amount.
  scaleRGB = pct: rgba:
    foldl (acc: channel: self.colors.scaleChannel channel pct acc) rgba [ "red" "green" "blue" ];

  # Inverts a color's red, green, and blue channels.
  invert = self.colors.applyRGB (v: maxComponent - v);

  # Returns whether this RGBA attrset is gamma-compressed.
  isGammaCompressed = rgba: rgba.compressed or true;

  # Returns the gamma-compressed RGB channels for an RGBA attrset.
  compressGamma = rgba:
    if self.colors.isGammaCompressed rgba then rgba
    else
      let
        compress = f: if f <= 0.0031308 then f * 12.92 else 1.055 * (self.math.pow f (1 / 2.4)) - 0.055;
      in self.colors.applyRGB (v: self.colors.applyComponentAsFloat compress v) rgba // { compressed = true; };

  # Returns the gamma-expanded RGB channels for an RGBA attrset.
  expandGamma = rgba:
    if !self.colors.isGammaCompressed rgba then rgba
    else
      let
        expand = f: if f <= 0.0405 then f / 12.92 else self.math.pow ((f + 0.055) / 1.055) 2.4;
      in self.colors.applyRGB (v: self.colors.applyComponentAsFloat expand v) rgba // { compressed = false; };

  # Returns the luminance Y of an RGBA attrset as a float between 0 and 1.
  luminance = rgba:
    let
      linear = self.colors.expandGamma rgba;
    in
      (self.colors.componentToFloat linear.red) * 0.2126
      + (self.colors.componentToFloat linear.green) * 0.7152
      + (self.colors.componentToFloat linear.blue) * 0.0722;

  # Returns the perceived brightness L* of an RGBA attrset as a float between 0 and 100.
  perceivedBrightness = rgba:
    let
      y = self.colors.luminance rgba;
    in
      if y <= (216.0 / 24389) then y * (24389.0 / 27)
      else (self.math.pow y (1.0 / 3)) * 116 - 16;

  # Returns the contrast ratio between two RGBA attrsets as a fraction.
  contrastRatio = c1: c2:
    let
      c1Y = self.colors.luminance c1;
      c2Y = self.colors.luminance c2;
    in
      clamp 21 (if c1Y > c2Y then (c1Y + 0.05) / (c2Y + 0.05) else (c2Y + 0.05) / (c1Y + 0.05));

  # Picks the RGBA attrset that has the most contrast from the given options.
  mostContrast = options: rgba:
    let
      comp = builtins.map (option: {
        inherit option;
        cr = self.colors.contrastRatio option rgba;
      }) options;
      selected = builtins.head (builtins.sort (o1: o2: o1.cr > o2.cr) comp);
    in selected.option;

  # Convert an RGBA attrset to a four-element list, with the alpha channel
  # first.
  toList = rgba: [ rgba.alpha rgba.red rgba.green rgba.blue ];

  # Convert an RGBA attrset to hex.
  toHex = rgba:
    let
      fmt = self.encoding.floatToFixedWidthHex 2;
    in
      (if self.colors.hasAlpha rgba then fmt rgba.alpha else "")
      + (fmt rgba.red)
      + (fmt rgba.green)
      + (fmt rgba.blue);

  # Convert an RGBA attrset to hex, always including the alpha channel.
  toHexAlpha = rgba:
    (self.encoding.floatToFixedWidthHex 2 rgba.alpha)
    + (self.colors.toHex (self.colors.updateAlpha maxComponent rgba));

  # Convert an RGBA attrset to hex, prefixed with a hash.
  toHex' = rgba: "#" + (self.colors.toHex rgba);

  # Convert an RGBA attrset to hex, prefixed with a hash and always including
  # the alpha channel.
  toHexAlpha' = rgba: "#" + (self.colors.toHexAlpha rgba);

  # Return a CSS expression for the RGBA attrset.
  toCSS = rgba:
    let
      params = "${builtins.toString (self.math.round rgba.red)}, ${builtins.toString (self.math.round rgba.green)}, ${builtins.toString (self.math.round rgba.blue)}";
    in
      if self.colors.hasAlpha rgba then "rgba(${params}, ${builtins.toString (self.colors.componentToFloat rgba.alpha)})"
      else "rgb(${params})";

  # Return an HTML/CSS-compatible color code for the RGBA attrset.
  toColorCode = rgba:
    let
      fmt = self.encoding.floatToFixedWidthHex 2;
    in
      "#"
      + (fmt rgba.red)
      + (fmt rgba.green)
      + (fmt rgba.blue)
      + (if self.colors.hasAlpha rgba then fmt rgba.alpha else "");

  # An option type for working with colors.
  type = types.submodule {
    options = {
      alpha = mkOption {
        type = types.ints.between 0 maxComponent;
        example = 128;
        default = self.colors.opaque;
        description = ''
          The alpha channel value for this color.
        '';
      };

      red = mkOption {
        type = types.ints.between 0 maxComponent;
        description = ''
          The red channel value for this color.
        '';
      };

      green = mkOption {
        type = types.ints.between 0 maxComponent;
        description = ''
          The red channel value for this color.
        '';
      };

      blue = mkOption {
        type = types.ints.between 0 maxComponent;
        description = ''
          The red channel value for this color.
        '';
      };
    };
  };
}

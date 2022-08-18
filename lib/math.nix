# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, lib, ... }: with lib;
let
  # Converge with a delta function of choice.
  converge' = df: f:
    let
      apply = x:
        let
          x' = f x;
        in if df x' x then x' else apply x';
    in apply;

  approxEq = epsilon: x': x: self.math.isNaN x' || self.math.abs (x' - x) < epsilon;

  # approxEq for values near 0.
  approxEq0 = approxEq 0.0000001;

  ln2 = 0.69314718055994530942;
in
{
  # Pi (constant).
  pi = 3.14159265358979323846;

  # Convert x to a float value.
  toFloat = x: x + 0.0;

  # Tests whether a float value is NaN.
  isNaN = x: isFloat x && x != x;

  # Negate the sign of x.
  negate = x: x * (-1);

  # Compute the absolute value of x.
  abs = x: if x < 0 then self.math.negate x else x;

  # Round x to the nearest integer.
  round = x:
    if x < 0 then self.math.negate (self.math.round (self.math.negate x))
    else
      let
        x' = builtins.floor x;
      in if (x - x') < 0.5 then x' else x' + 1;

  # Compute the reciprocal of x.
  reciprocal = x: 1.0 / x;

  # Compute an approximation of e^x.
  exp = x:
    if x < 0 then self.math.reciprocal (self.math.exp (self.math.negate x))
    else
      let
        op = { sum, n, x' }:
          let
            x'' = x' / n * x;
          in { sum = sum + x''; n = n + 1; x' = x''; };
        r = converge' (acc': acc: acc'.sum == acc.sum) op { sum = 1.0; n = 1; x' = 1.0; };
      in r.sum;

  # Compute the approximate square root of x.
  sqrt = x:
    assert assertMsg (x >= 0) "sqrt: undefined for x < 0";
    if x == 0 then 0
    else converge (x': (x' + x / x') / 2) 1.0;

  # Compute the approximate arithmetic-geometric mean M(x, y).
  agm = x: y:
    assert assertMsg ((x >= 0 && y >= 0) || (x <= 0 && y <= 0)) "agm: undefined for x * y < 0";
    if approxEq0 x y then x
    else
      let
        xf = self.math.toFloat x;
        yf = self.math.toFloat y;
      in self.math.agm ((xf + yf) / 2) (self.math.sqrt (xf * yf));

  # Compute an approximation of ln(x).
  ln = x:
    assert assertMsg (x > 0) "ln: undefined for x <= 0";
    self.math.pi / (2 * (self.math.agm 1 (4 / (4096.0 * x)))) - 12 * ln2;

  # Compute base b logarithm of x.
  log = b: x: (self.math.ln x) / (self.math.ln b);

  # Compute base 10 logarithm.
  log10 = self.math.log 10;

  # Compute base 2 logarithm.
  log2 = self.math.log 2;

  # Compute x to the power p, where either may be floats. Always returns a
  # float to give useful information about overflow.
  pow = x: p:
    if p < 0 then self.math.pow (self.math.reciprocal x) (self.math.negate p)
    else if builtins.isInt p then
      let
        f = self.math.toFloat x;
      in
        if p == 0 then 1
        else if builtins.bitAnd p 1 == 1 then f * (self.math.pow (f * f) ((p - 1) / 2))
        else self.math.pow (f * f) (p / 2)
    else
      let
        ipart = builtins.floor p;
        fpart = p - ipart;

        ip = self.math.pow x ipart;
        fp = self.math.exp (fpart * (self.math.ln x));
      in ip * fp;
}

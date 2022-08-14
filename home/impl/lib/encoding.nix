# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, lib, ... }: with lib;
let
  hex = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" ];
  hexLength = length hex;
  hexToIntTable = builtins.listToAttrs (imap0 (flip nameValuePair) hex);
in
{
  hexToInt = hex:
    foldl (acc: ch: acc * hexLength + hexToIntTable.${toUpper(ch)}) 0 (stringToCharacters hex);
  intToHex = int:
    let
      rem = mod int hexLength;
      ch = builtins.head (drop rem hex);
    in
      if int == rem then ch
      else (self.encoding.intToHex (int / hexLength)) + ch;
  intToFixedWidthHex = width: int: fixedWidthString width "0" (self.encoding.intToHex int);

  floatToHex = f: if isFloat f then self.encoding.intToHex (self.math.round f) else self.encoding.intToHex f;
  floatToFixedWidthHex = width: f: fixedWidthString width "0" (self.encoding.floatToHex f);

  hexToBytes = hex:
    map (offset: self.encoding.hexToInt (builtins.substring (offset * 2) 2 hex))
      (range 0 ((builtins.stringLength hex - 2) / 2));
}

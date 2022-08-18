# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, lib, ... }: with lib;
let
  parseDescriptor = data:
    # Make sure this is a timing descriptor. Otherwise we ignore it.
    if sublist 0 2 data == [ 0 0 ] then
      {
        type = "display";
      }
    else
      {
        type = "detailedTiming";
        horizontalActivePixels = (builtins.elemAt data 2)
          + (builtins.bitAnd (builtins.elemAt data 4) 240) * 16;
        verticalActivePixels = (builtins.elemAt data 5)
          + (builtins.bitAnd (builtins.elemAt data 7) 240) * 16;
      };

  parseDescriptorInEDIDBytes = n:
    assert (assertMsg (n >= 0 && n < 4) "Only 4 descriptors are supported");
    data: parseDescriptor (sublist (54 + (n * 18)) 18 data);
in
{
  # Parse EDID data presented as a byte array, returning information we care
  # about as an attrset.
  parseEDIDBytes = data:
    let
      checksum = builtins.foldl' (x: y: mod (x + y) 256) 0 (sublist 0 128 data);
    in
      assert (assertMsg (builtins.length data >= 128) "EDID is too short");
      assert (assertMsg (builtins.elemAt data 18 == 1) "Unknown EDID version");
      assert (assertMsg (builtins.elem (builtins.elemAt data 19) [3 4]) "Unknown EDID revision");
      assert (assertMsg (checksum == 0) "EDID checksum is invalid");
      {
        descriptors = map (n: parseDescriptorInEDIDBytes n data) [ 0 1 2 3 ];
      };

  # Parse EDID data presented as a hexadecimal string, returning information we
  # care about as an attrset.
  parseEDIDHex = hex: self.edid.parseEDIDBytes (self.encoding.hexToBytes hex);
}

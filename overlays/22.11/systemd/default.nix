# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

self: super: {
  systemd = super.systemd.overrideAttrs (old: {
    patches = old.patches ++ [
      # https://github.com/systemd/systemd/pull/23848
      ./fix-device-wants-inactive.patch
    ];
  });
}

# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  # https://bugzilla.kernel.org/show_bug.cgi?id=203709
  boot.extraModprobeConfig = ''
    options iwlmvm power_scheme=1
    options iwlwifi power_save=0
  '';
}

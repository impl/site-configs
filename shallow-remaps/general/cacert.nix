# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

pkgs: {
  # Rewrite just the top-level cacert so OS-level consumers get the
  # dependency on our filtered version.
  cacert = pkgs.cacert-filtered;
}

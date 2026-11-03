# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ python3Packages, writers }:
writers.writePython3Bin "certdata-filter" { libraries = [ python3Packages.buildcatrust ]; }
  ./certdata-filter.py

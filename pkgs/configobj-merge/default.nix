# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ python3Packages, writers, ... }:
writers.writePython3Bin "configobj-merge" { libraries = [ python3Packages.configobj ]; } ./configobj-merge.py

# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, ...}: with lib; {
  # QEMU supports a mode where it exposes itself as Hyper-V, but it doesn't
  # actually map all the corresponding services into the VM unless you ask it
  # to.
  systemd.services."hv-kvp".unitConfig = mkIf (builtins.elem config.boot.kernelPackages.hyperv-daemons.lib config.systemd.packages) {
    ConditionPathExists = [ "/dev/vmbus/hv_kvp" ];
  };
}

# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable (mkMerge [
  {
    services.polybar = {
      enable = true;
      package = let
        polybar = pkgs.polybar.overrideAttrs (old: {
          version = "unstable-2022-02-06";
          src = pkgs.fetchFromGitHub {
            owner = "polybar";
            repo = "polybar";
            rev = "ab915fb724546e7abfcb35cbaf863ce2bca613ec";
            sha256 = "sha256-HE6CbO5ImFwMxlhQTSPiayMM60fyW94av0Qc5FHjQWY=";
            fetchSubmodules = true;
          };
          buildInputs = old.buildInputs ++ [ pkgs.libuv ];
          prePatch = ''
            substituteInPlace CMakeLists.txt --replace /etc "$out/etc"
            substituteInPlace src/utils/file.cpp --replace /etc "$out/etc"
            substituteInPlace contrib/bash/polybar --replace 'etc_path=/etc' "etc_path=$out/etc"
            substituteInPlace contrib/zsh/_polybar --replace 'etc_path=/etc' "etc_path=$out/etc"
          '';
          patches = [
            ./remove-ewmh-checks.patch
          ];
        });
      in polybar.override {
        githubSupport = true;
        pulseSupport = true;
      };
      settings = let
        wirelessModules = listToAttrs (map (interface: let
          def = {
            type = "internal/network";
            format.connected = "<ramp-signal> <label-connected>";

            inherit interface;
            ramp.signal = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
            label.connected = "%essid%";
          };
        in nameValuePair "net-${interface}" def) (if machineConfig.networking.wireless.enable then machineConfig.networking.wireless.interfaces else []));
      in {
        "colors" = {
          "text" = "#2e3436";
          "transparent" = "#00f6f5f4";
          "background" = "#ddf6f5f4";
          "urgent" = "#99ff6d4f";
        };
        "global/wm" = {
          margin.top = 0;
          margin.bottom = 0;
        };
        "settings" = {
          format = {
            foreground = "\${colors.text}";
            background = "\${colors.background}";
            padding = 4;
          };

          screenchange.reload = true;
        };
        "bar/top" = {
          monitor = "\${env:MONITOR}";
          width = "100%";
          height = "25";
          radius = 6.0;
          fixed.center = true;

          font = [
            "Noto Sans:size=10;2"
            "Noto Sans Symbols:size=10;2"
            "Noto Sans Symbols2:size=10;2"
            "Noto Sans Math:size=10;2"
            "Material Design Icons:size=13;3"
            "Material Icons:size=13;4"
          ];

          foreground = "\${colors.text}";
          background = "\${colors.transparent}";
          padding = 2;
          module.margin = {
            left = 1;
            right = 1;
          };

          cursor.click = "pointer";

          modules = {
            left = concatStringsSep " " ([ "time" "date" ] ++ (attrNames wirelessModules) ++ [ "workspaces "]);
            right = "title";
          };

          wm.restack = "generic";
          override.redirect = true;

          enable.ipc = true;
        };
        "module/time" = {
          type = "internal/date";
          format = " <label>";

          interval = 1;
          date = "%e %b";
          time = "%H:%M:%S";
          label = "%time%";
        };
        "module/date" = {
          type = "internal/date";
          format = " <label>";

          interval = 1;
          date = "%e %b";
          time = "%H:%M:%S";
          label = "%date%";
        };
        "module/workspaces" = {
          type = "internal/xworkspaces";
          format = {
            text = "<label-state>";
            padding = 0;
          };

          label = builtins.foldl' recursiveUpdate {} [
            (genAttrs [ "active" "urgent" "empty" "occupied" ] (type: {
              text = "%name%";
              padding = 4;
              background = "\${colors.background}";
            }))
            {
              active.background = "#88f6f5f4";
              urgent.background = "\${colors.urgent}";
              empty.foreground = "#882e3436";
            }
          ];
        };
        "module/title" = {
          type = "internal/xwindow";
        };
      } // (mapAttrs' (name: nameValuePair "module/${name}") wirelessModules);
      script = ''
        polybar top &
      '';
    };
  }
  (mkIf (machineConfig.networking.hostName == "beignet") {
    services.polybar.settings = {
      "bar/top" = {
        monitor = mkForce "\${env:MONITOR:HDMI1}";
      };
    };
  })
])

# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, libX, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable (mkMerge [
  {
    profiles.theme.font.packages = with pkgs; [
      material-design-icons
      material-icons
    ];

    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
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

        batteryModules = listToAttrs (map (battery: let
          textColor = with libX.colors; toHex' (scaleAlpha (-45) config.profiles.theme.colors.text);
          def = {
            type = "internal/battery";
            time.format = "%H:%M";
            format.full = "󱐋";
            format.charging = "󰂄 <label-charging>";
            format.discharging = "<ramp-capacity> <label-discharging>";

            inherit battery;
            inherit (machineConfig.profiles.hardware.power) adapter;
            ramp.capacity = [ "󱃍" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            label.charging = "%percentage%% %{F${textColor}}%time%%{F-}";
            label.discharging = "%percentage%% %{F${textColor}}%time%%{F-}";
          };
        in nameValuePair "bat-${battery}" def) (if machineConfig.profiles.hardware.power.adapter != null then machineConfig.profiles.hardware.power.batteries else []));

        machineModules = wirelessModules // batteryModules;
      in {
        "colors" = with config.profiles.theme.colors; with libX.colors; {
          "text" = toHex' text;
          "transparent" = toHex' (updateAlpha 0 primary);
          "background" = toHex' (scaleAlpha (-15) primary);
          "urgent" = toHex' (scaleAlpha (-40) urgent);
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

          font =
            builtins.map (font: "${font}:size=${builtins.toString config.profiles.theme.font.size};2")
              ([ config.profiles.theme.font.generalFont ] ++ config.profiles.theme.font.extraFonts)
            ++ [
              "Material Design Icons:size=13;4"
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
            left = concatStringsSep " " ([ "time" "date" ] ++ (attrNames machineModules) ++ [ "workspaces "]);
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
            text = "<label-monitor><label-state>";
            padding = 0;
          };

          label = with config.profiles.theme.colors; with libX.colors; builtins.foldl' recursiveUpdate {} [
            (genAttrs [ "monitor" "active" "urgent" "empty" "occupied" ] (type: {
              text = "%name%";
              padding = 4;
              background = "\${colors.background}";
            }))
            {
              monitor.text = "󰍹";
              active.background = toHex' (scaleAlpha (-45) primary);
              urgent.background = "\${colors.urgent}";
              empty.foreground = toHex' (scaleAlpha (-45) text);
            }
          ];
        };
        "module/title" = {
          type = "internal/xwindow";
        };
      } // (mapAttrs' (name: nameValuePair "module/${name}") machineModules);
      script = ''
        polybar top &
      '';
    };

    # Starting Polybar too early causes it to miss the presence of
    # _NET_ACTIVE_WINDOW for the WM, so we actually want to wait until EWMH are
    # provided.
    systemd.user.services.polybar = {
      Unit = {
        Requires = [ "xmonad.service" ];
        After = [ "xmonad.service" ];
      };
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

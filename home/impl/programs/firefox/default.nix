# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, pkgsX, ... }: with lib; {
  options = let
    multiUserContainerIdentity = types.submodule {
      options = {
        userContextId = mkOption {
          type = types.ints.between 1 config.programs.firefox.multiUserContainers.maxUserContextId;
          description = ''
            The unique context identifier for this identity.
          '';
        };

        name = mkOption {
          type = types.str;
          description = ''
            A friendly (or internationalizable) name to show for this identity.
          '';
        };

        icon = mkOption {
          type = types.str;
          default = "tree";
          description = ''
            An icon name to associate with this identity.
          '';
        };

        color = mkOption {
          type = types.str;
          default = "";
          description = ''
            A color name to associate with this identity.
          '';
        };

        public = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether the identity should be shown to the user.
          '';
        };
      };
    };
  in {
    programs.firefox = {
      multiUserContainers = {
        maxUserContextId = mkOption {
          type = types.int;
          description = ''
            The largest available user context ID value.
          '';
        };

        identities = mkOption {
          type = types.listOf multiUserContainerIdentity;
          description = ''
            The identities to attach to this Firefox profile.
          '';
        };
      };
    };
  };

  config = mkIf machineConfig.profiles.gui.enable {
    programs.firefox = {
      enable = true;
      multiUserContainers = {
        maxUserContextId = 4294967295;
        identities = mkMerge [
          (mkOrder 350 [
            { userContextId = 1; name = "Personal"; icon = "fingerprint"; color = "green"; }
          ])
          (mkOrder 650 [
            { userContextId = 2; name = "Work (Montviridian)"; icon = "briefcase"; color = "yellow"; }
            { userContextId = 3; name = "Work (MBCoA)"; icon = "briefcase"; color = "red"; }
          ])
          (mkOrder 1250 [
            { userContextId = 4; name = "Temporary"; color = "orange"; }
          ])
          (mkAfter [
            { userContextId = 5; name = "userContextIdInternal.thumbnail"; public = false; }
            {
              userContextId = config.programs.firefox.multiUserContainers.maxUserContextId;
              name = "userContextIdInternal.webextStorageLocal";
              public = false;
            }
          ])
        ];
      };

      package = let
        containersJSON = let
          identities = config.programs.firefox.multiUserContainers.identities;
          conflicts = filterAttrs (_: identities: length identities > 1)
            (groupBy (identity: builtins.toString identity.userContextId) identities);
          text = builtins.toJSON {
            version = 4;
            inherit identities;
            lastUserContextId = builtins.foldl' (acc: identity:
              if identity.userContextId >= acc && identity.userContextId < config.programs.firefox.multiUserContainers.maxUserContextId
              then identity.userContextId + 1
              else acc
            ) 1 identities;
          };
        in
          assert assertMsg (conflicts == {}) ''
            The values for userContextId must be globally unique. Conflicts:${concatStrings (mapAttrsToList (userContextId: conflicts:
              "\n- ${userContextId}: ${concatStringsSep ", " (map (conflict: conflict.name) conflicts)}"
            ) conflicts)}
          '';
          pkgs.writeText "containers.json" text;
        # Firefox will blindly overwrite symlinks if we're not careful, so instead
        # of simply using a home.file configuration option for some profile data,
        # we wrap the process and bind mount the relevant files (read only, of
        # course).
        firefox = pkgs.firefox.override {
          extraPrefs = ''
            lockPref('extensions.autoDisableScopes', 0);
          '';
          extraPolicies = {
            DisableFirefoxAccounts = true;
            DisablePocket = true;
            DisableProfileImport = true;
            DisableProfileRefresh = true;
            DisableSetDesktopBackground = true;
            DisableTelemetry = true;
            DisplayBookmarksToolbar = false;
            DNSOverHTTPS = {
              Enabled = false;
              Locked = true;
            };
            FirefoxHome = {
              Pocket = false;
              Snippets = false;
            };
            NoDefaultBookmarks = true;
            OfferToSaveLogins = false;
            UserMessaging = {
              ExtensionRecommendations = false;
              SkipOnboarding = true;
            };
          };
        };
        bubblewrappedFirefox = extraArgs: let
          finalFirefox = firefox.override extraArgs;
        in pkgsX.buildBubblewrap {
          name = "firefox";
          inherit (finalFirefox) meta passthru;
          bwrapArgs = [
            "--bind" "/" "/"
            "--dev-bind" "/dev" "/dev"
            "--ro-bind" "${containersJSON}" "${config.home.homeDirectory}/.mozilla/firefox/${config.programs.firefox.profiles."impl".path}/containers.json"
            "--die-with-parent"
            "--new-session"
          ];
          runScript = "${finalFirefox}/bin/firefox";
          extraInstallCommands = ''
            shopt -s extglob
            for orig in ${finalFirefox}/!(bin); do
              ln -sn $orig $out
            done
          '';
        };
      in makeOverridable bubblewrappedFirefox {};
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        multi-account-containers
        ublock-origin
        (import ./kee.nix { inherit lib pkgs; })
      ];
      profiles."impl" = {
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.enhanced" = false;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.uiCustomization.state" = builtins.toJSON({
            "placements" = {
              "widget-overflow-fixed-list" = [];
              "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "home-button"
                "urlbar-container"
                "search-container"
                "downloads-button"
                "ublock0-button"
                "containers-panelmenu"
                "ublock0_raymondhill_net-browser-action"
                "keefox_chris_tomlinson-browser-action"
                "screenshots_mozilla_org-browser-action"
                "_testpilot-containers-browser-action"
              ];
              "toolbar-menu" = [
                "menubar-items"
              ];
              "TabsToolbar" = [
                "tabbrowser-tabs"
                "new-tab-button"
                "alltabs-button"
              ];
              "PersonalToolbar" = [
                "personal-bookmarks"
                "managed-bookmarks"
              ];
            };
            "seen" = [];
            "dirtyAreaCache" = [];
            "currentVersion" = 17;
            "newElementCount" = 4;
          });
        };
      };
    };

    sops.secrets."programs/firefox/managed-storage-uBlock0@raymondhill.net" = {
      sources = [
        {
          file = ./. + "/managed-storage-uBlock0@raymondhill.net.sops.yaml";
          outputType = "json";
        }
      ];
    };

    home.file.".mozilla/managed-storage/uBlock0@raymondhill.net.json" = {
      source = config.sops.secrets."programs/firefox/managed-storage-uBlock0@raymondhill.net".target;
    };
  };
}

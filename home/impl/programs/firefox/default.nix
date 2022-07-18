# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, pkgsX, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.firefox = let
    containersJSON = let
      maxUserContextId = 4294967295;
      mkIdentity = args@{ userContextId, name, icon ? "tree", color ? "", public ? true }: {
        inherit userContextId name icon color public;
      };
      text = builtins.toJSON rec {
        version = 4;
        identities = [
          (mkIdentity { userContextId = 1; name = "Personal"; icon = "fingerprint"; color = "green"; })
          (mkIdentity { userContextId = 2; name = "Work (Montviridian)"; icon = "briefcase"; color = "yellow"; })
          (mkIdentity { userContextId = 3; name = "Work (MBCoA)"; icon = "briefcase"; color = "red"; })
          (mkIdentity { userContextId = 4; name = "Temporary"; color = "orange"; })
          (mkIdentity { userContextId = 5; name = "userContextIdInternal.thumbnail"; public = false; })
          (mkIdentity { userContextId = maxUserContextId; name = "userContextIdInternal.webextStorageLocal"; public = false; })
        ];
        lastUserContextId = builtins.foldl' (acc: identity:
          if identity.userContextId >= acc && identity.userContextId < maxUserContextId then identity.userContextId + 1 else acc
        ) 1 identities;
      };
    in pkgs.writeText "containers.json" text;
  in
  {
    enable = true;
    package = let
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
          DisableTelemetry = true;
          DisablePocket = true;
          DisplayBookmarksToolbar = false;
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
          DNSOverHTTPS = {
            Enabled = false;
            Locked = true;
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
}

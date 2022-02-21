# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
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
      };
    };
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

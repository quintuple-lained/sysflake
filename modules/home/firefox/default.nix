{ pkgs
, inputs
, ...
}:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts = [ pkgs.firefoxpwa ];

    # Manage Firefox settings
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      # Manage extensions per-profile (new format)
      extensions = {
        force = true;
        packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          ublock-origin
          bitwarden
          darkreader
          vimium
        ];
      };

      bookmarks = {
        force = true;
        settings = [
          {
            name = "Bookmarks Toolbar";
            toolbar = true;
            bookmarks = [
              {
                name = "NixOS Packages";
                url = "https://search.nixos.org/packages";
              }
              {
                name = "Proton Mail";
                url = "https://mail.proton.me";
              }
              {
                name = "Reddit";
                url = "https://reddit.com";
              }
              {
                name = "Youtube";
                url = "https://youtube.com";
              }
              {
                name = "Wikipedia";
                url = "https://en.wikipedia.org";
              }
              {
                name = "Github";
                url = "https://github.com";
              }
              {
                # twitter is entirely unsuable at this point, bluesky is shit as well but its less shit
                name = "Twitter";
                url = "https://bsky.app";
              }
              {
                name = "Jelly";
                url = "media.insanitypost.ing";
              }
              {
                name = "drives";
                url = "https://diskprices.com/?locale=de";
              }
            ];
          }
        ];
      };

      # Manage search engines
      search = {
        force = true;
        default = "ddg";
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "NixOS Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "options";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "Home Manager Options" = {
            urls = [
              {
                template = "https://nix-community.github.io/home-manager/options.html";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = [ "@hm" ];
          };
        };
      };

      # Firefox settings (about:config)
      settings = {
        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.partition.network_state" = false;
        "privacy.donottrackheader.enabled" = true;

        # Security settings
        "security.tls.insecure_fallback_hosts" = "";
        "security.tls.unrestricted_rc4_fallback" = false;

        # Disable telemetry
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;

        # UI preferences
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.shortcuts.tabs" = false;

        # Enable vertical tabs
        "sidebar.verticalTabs" = true;

        # Performance settings
        "browser.cache.disk.enable" = true;
        "browser.cache.memory.enable" = true;
        "browser.sessionstore.interval" = 15000;

        # Downloads
        "browser.download.useDownloadDir" = true;
        "browser.download.dir" = "/home/$(whoami)/Downloads";

        "browser.toolbar.bookmarks.visibility" = "newtab";

        # Developer tools
        "devtools.theme" = "dark";
        "devtools.toolbox.footer.height" = 250;

        "dom.webnotifications.enabled" = true;
        "dom.webnotifications.serviceworker.enabled" = true;
        "dom.serviceWorkers.enabled" = true;
        "dom.push.enabled" = true;
        "browser.ssb.enabled" = true;
        "dom.manifest.enabled" = true;
        "dom.webcomponents.enabled" = true;
        "dom.push.connection.enabled" = true;
      };
    };
  };
}

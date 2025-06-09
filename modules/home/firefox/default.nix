{
  pkgs,
  inputs,
  ...
}:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    
    # Manage extensions
    extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
      ublock-origin
      bitwarden
      darkreader
      vimium
    ];

    # Manage Firefox settings
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
        
        # Manage bookmarks
        bookmarks = [
          {
            name = "Nix Sites";
            bookmarks = [
              {
                name = "NixOS Options";
                url = "https://search.nixos.org/options";
              }
              {
                name = "Home Manager Options";
                url = "https://nix-community.github.io/home-manager/options.html";
              }
              {
                name = "Nixpkgs Manual";
                url = "https://nixos.org/manual/nixpkgs/stable/";
              }
            ];
          }
          {
            name = "Development";
            bookmarks = [
              {
                name = "GitHub";
                url = "https://github.com";
              }
            ];
          }
        ];

        # Manage search engines
        search = {
          force = true;
          default = "DuckDuckGo";
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            
            "NixOS Options" = {
              urls = [{
                template = "https://search.nixos.org/options";
                params = [
                  { name = "type"; value = "options"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };

            "Home Manager Options" = {
              urls = [{
                template = "https://nix-community.github.io/home-manager/options.html";
                params = [
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
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
          "browser.download.useDownloadDir" = true; # Always ask where to save
          "browser.download.dir" = "/home/$(whoami)/Downloads";
          
          # Developer tools
          "devtools.theme" = "dark";
          "devtools.toolbox.footer.height" = 250;
        };
      };
    };
  };
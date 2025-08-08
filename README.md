# My Nix config

## TODO

- [x] add SOPS + age
- [ ] fix the issue spawner

## Services

| from wolfgang     | is?                           | need?                     | mine                  | done?                     |
| ---               |---                            |---                        |---                    |---                        |
| bazarr            | subtitles downloader          | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| jellyseerr        | media requester               | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| lidarr            | music collection manager      | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| prowlarr          | index manager                 | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| radarr            | movie organiser/manager       | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| sonarr            | downloader                    | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| audiobookshelf    | audiobook and podcast server  | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| backup            | backup setup                  | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| deemix            | deezer downloader             | :heavy_multiplication_x:  | yt-dlp-web-ui         | :heavy_multiplication_x:  |
| deluge            | torrent                       | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| homepage          | application dashboard         | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| immich            | photo and video manager       | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| jellyfin          | jellyfin, duh, netflix at home| :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| keycloak          | identity and access manager   | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| microbin          | filesharing and url shortening| :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| miniflux          | feed reader                   | :heavy_multiplication_x:  | no need               | :heavy_multiplication_x:  |
| navidrome         | music collection server/stream| :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| ocis              | file sync and share           | :heavy_multiplication_x:  | ill do something else | :heavy_multiplication_x:  |
| paperless-ngx     | document management system    | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| radicale          | calendar and contact server   | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| sabnzbd           | usenet download tool          | :heavy_multiplication_x:  |                       | :heavy_multiplication_x:  |
| slskd             | soulseek                      | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| homeassistant     | homeassistant                 | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| uptime-kuma       | uptime watcher                | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| vaultwarden       | bitwarden but better          | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| wireguard-netns   | wireguard namespace setup     | :heavy_check_mark:        |                       | :heavy_multiplication_x:  |
| backup            | restic and db backups         | :heavy_multiplication_x:  | smth custom, later    | :heavy_multiplication_x:  |

my setup:
Services
-acquisitions
--vpn.nix
--torrent.nix
--soulseek.nix
--default.nix

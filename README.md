# My Nix config

## TODO

- [x] add SOPS + age
- [ ] fix the issue spawner

## Services

| from wolfgang     | is?                           | need? | mine                  | done? |
| ---               |---                            |---    |---                    |---    |
| bazarr            | subtitles downloader          | [ x ] |                       | [   ] |
| jellyseerr        | media requester               | [ x ] |                       | [   ] |
| lidarr            | music collection manager      | [ x ] |                       | [   ] |
| prowlarr          | index manager                 | [ x ] |                       | [   ] |
| radarr            | movie organiser/manager       | [ x ] |                       | [   ] |
| sonarr            | downloader                    | [ x ] |                       | [   ] |
| audiobookshelf    | audiobook and podcast server  | [ x ] |                       | [   ] |
| backup            | backup setup                  | [ x ] |                       | [   ] |
| deemix            | deezer downloader             | [   ] | yt-dlp-web-ui         | [   ] |
| deluge            | torrent                       | [ x ] |                       | [   ] |
| homepage          | application dashboard         | [ x ] |                       | [   ] |
| immich            | photo and video manager       | [ x ] |                       | [   ] |
| jellyfin          | jellyfin, duh, netflix at home| [ x ] |                       | [   ] |
| keycloak          | identity and access manager   | [ x ] |                       | [   ] |
| microbin          | filesharing and url shortening| [ x ] |                       | [   ] |
| miniflux          | feed reader                   | [   ] | no need               | [   ] |
| navidrome         | music collection server/stream| [ x ] |                       | [   ] |
| ocis              | file sync and share           | [   ] | ill do something else | [   ] |
| paperless-ngx     | document management system    | [ x ] |                       | [   ] |
| radicale          | calendar and contact server   | [ x ] |                       | [   ] |
| sabnzbd           | usenet download tool          | [ x ] |                       | [   ] |
| slskd             | soulseek                      | [ x ] |                       | [   ] |
| homeassistant     | homeassistant                 | [ x ] |                       | [   ] |
| uptime-kuma       | uptime watcher                | [ x ] |                       | [   ] |
| vaultwarden       | bitwarden but better          | [ x ] |                       | [   ] |
| wireguard-netns   | wireguard namespace setup     | [ x ] |                       | [   ] |
| backup            | restic and db backups         | [   ] | smth custom, later    | [   ] |

my setup:
Services
-acquisitions
--vpn.nix
--torrent.nix
--soulseek.nix
--default.nix

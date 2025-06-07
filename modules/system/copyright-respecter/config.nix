{ pkgs, config, lib, ... }:

{
  imports = [
    ./hardware-config.nix
    ../../srv/ssh/ssh-server.nix
    #../../srv/services/vpn-server.nix
    #../../srv/services/jellyfin.nix
    #../../srv/services/nextcloud.nix
    #../../srv/services/torrent.nix
    #../../srv/services/pihole.nix
  ];
  
  networking = {
    hostName = "copyright-respecter";
    hostId = builtins.substring 0 8 (builtins.hashString "sha256" hostName);
    networkmanager.enable = true;
    useDHCP = false;

    interfaces.enp34s0 = {
		ipv4.addresses = [
			{ 
				address = "192.168.178.109"; 
				prefixLength = 24; 
			}
			];		
		};
	defaultGateway = {
		address = "192.168.178.1";
		interface = "enp34s0";
		};
  };
    # Set your time zone.
  time.timeZone = "Europe/Berlin";
}
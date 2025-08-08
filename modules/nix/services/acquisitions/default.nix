{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ./vpn-ns.nix
    ./slskd.nix
  ];
}

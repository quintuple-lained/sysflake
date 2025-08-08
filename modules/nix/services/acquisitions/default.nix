{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ../../services/acquisitions/vpn-ns.nix
  ];
}

{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ./nextcloud.nix
  ];
}

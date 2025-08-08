{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ./postgres.nix
  ];
}

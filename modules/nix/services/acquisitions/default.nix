{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ../../services/acquisitions
  ];
}

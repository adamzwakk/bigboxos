{
  pkgs,
  lib,
  ...
}:
{
  # Maybe make each its own config file if we have to
  environment.systemPackages = with pkgs; [
    dosbox-staging         # DOSBox
    umu-launcher           # Steam/Proton
    scummvm                # ScummVM
    vcmi                   # HoMM 3
  ];
}
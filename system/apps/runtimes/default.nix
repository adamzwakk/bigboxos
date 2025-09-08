{
  pkgs,
  lib,
  ...
}:
{
  # Maybe make each its own config file if we have to
  environment.systemPackages = with pkgs; [
    dosbox-staging         # DOSBox
    ecwolf                 # Wolf3D
    # umu-launcher           # Steam/Proton
    scummvm                # ScummVM
    # vcmi                   # HoMM 3
  ];
}
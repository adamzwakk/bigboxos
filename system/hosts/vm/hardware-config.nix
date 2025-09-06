{
  pkgs,
  lib,
  flake-inputs,
  ...
}:
{
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };
  boot.loader.grub.device = "nodev";
}
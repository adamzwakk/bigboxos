{ pkgs, config, lib, ...}:
{
  home.file."/.config/ecwolf/ecwolf.cfg" = {
    source = ./ecwolf.cfg;
  };
}
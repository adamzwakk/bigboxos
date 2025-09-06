{
  pkgs,
  lib,
  ...
}:
{
  # Maybe make each its own config file if we have to
  environment.systemPackages = with pkgs; [
    cage                # Kiosk Mode
  ];
}
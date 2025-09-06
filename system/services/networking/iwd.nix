{ pkgs, config, ... }:
{
  networking.wireless.iwd = {
    enable = true;
    settings = {
      IPv6 = {
        Enabled = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };

  networking.networkmanager.wifi.backend =
    if config.networking.networkmanager.enable then "iwd" else null;

  environment.systemPackages = with pkgs; [
    impala
  ];
}
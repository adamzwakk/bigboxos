{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Maybe make each its own config file if we have to
  environment.systemPackages = with pkgs; [
    cage                # Kiosk Mode
  ];


  home-manager.users.bbadmin = {
    home.packages = with pkgs; [ 
      #yazi
    ];

    home.stateVersion = "25.05";
  };
}
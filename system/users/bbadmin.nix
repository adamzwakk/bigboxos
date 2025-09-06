{ pkgs, config, lib, ... }: {
  users.users.bbadmin = {
    initialPassword = "bbadmin";
    isNormalUser = true;
    extraGroups = [ "wheel" "kvm" ]
      ++ lib.optionals config.networking.networkmanager.enable [
        "networkmanager"
      ];
    shell = pkgs.bash;
  };

  home-manager.users.bbadmin = {

    home.stateVersion = "25.05";
  };
}

{ pkgs, config, lib, ... }: {
  users.users.bbuser = {
    linger = true;
    initialPassword = "bbuser";
    isNormalUser = true;
    extraGroups = [ "kvm" "video" "input" "audio" ]
      ++ lib.optionals config.networking.networkmanager.enable [
        "networkmanager"
      ];
    shell = pkgs.bash;
  };
}

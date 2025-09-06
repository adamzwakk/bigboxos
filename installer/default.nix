{ pkgs, lib, ... }:

{
  # Temporary root to satisfy ISO build
  fileSystems."/" = {
    device = "/dev/dummy";
    fsType = "tmpfs";
  };

  boot.loader.grub.device = "nodev";
  users.users.root.password = "";

  environment = {
    systemPackages = with pkgs; [
      util-linux
      parted
      git
      dialog   # classic ncurses menus
      gum      # pretty TUI prompts
      jq
    ];

    etc."installer/run.sh" = {
      source = ./run.sh;
      mode = "0755"; # make executable
    };
    etc."installer/src" = {
      source = ../.;
    };
  };

  services.getty.autologinOnce = false;

  #isoImage.splashImage = ./img/wallpaper_8191_800x600.jpg;
  isoImage.configurationName = "BigBoxOS Installer";
  systemd.services = {
    #systemd-networkd-wait-online.enable = true;
    "getty@tty1".enable = false;

    installer-dialog = {
      description = "Run BBOS installer dialog";
      wantedBy = [ "multi-user.target" ];
      after = [ "getty@tty1.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bash}/bin/bash /etc/installer/run.sh";
        Environment = "PATH=/run/current-system/sw/bin";
        StandardInput = "tty";
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
        TTYReset = true;
        TTYVHangup = true;
      };
    };
  };
}
{ pkgs, lib, ... }:

{
  # Temporary root to satisfy ISO build
  fileSystems."/" = {
    device = "/dev/dummy";
    fsType = "tmpfs";
  };

  boot.loader.grub.device = "nodev";

  # Base packages for installer
  environment.systemPackages = with pkgs; [
    git
    dialog   # classic ncurses menus
    gum      # pretty TUI prompts
    jq
  ];

  # Remove autologin to avoid tty conflicts
  # Disable nixos user autologin
  users.users.nixos = lib.mkIf false {
    isNormalUser = true;
  };

  # Add root user and autologin
  users.users.root = {
    isNormalUser = false;
    password = "";
  };

  services.getty.autologinUser = lib.mkForce "root";  

  # Copy installer script and source code into ISO
  environment.etc."installer/run.sh" = {
    source = ./run.sh;
    mode = "0755"; # make executable
  };
  environment.etc."installer/src" = {
    source = ../src;
  };

  #isoImage.splashImage = ./img/wallpaper_8191_800x600.jpg;
  isoImage.volumeID = "BigBoxOS";

  systemd.services.installer = {
    description = "Custom Guided Installer";
    after = [ "getty@tty1.service" ];
    wants = [ "getty@tty1.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart="/bin/bash /etc/installer/run.sh";
      StandardInput="tty";
      StandardOutput="tty";
      StandardError="tty";
      TTYPath=/dev/tty1;
      User="root";
      RemainAfterExit=false;
    };
  };
}
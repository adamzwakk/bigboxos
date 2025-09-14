{
  pkgs,
  lib,
  config,
  flake-inputs,
  ...
}:
let
  kioskUser = "bbuser";
  bbuid = config.users.users.${kioskUser}.uid;

  cartMount = "/mnt/cartridge";

  allowedRuntimes = {
    scummvm = "${pkgs.scummvm}/bin/scummvm";
    dosbox = "${pkgs.dosbox}/bin/dosbox";
    ecwolf = "${pkgs.ecwolf}/bin/ecwolf";
  };

  whitelistFile = pkgs.writeText "kiosk-whitelist" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: binPath: "${name}=${binPath}") allowedRuntimes
    )
  );

  mountCartridge = pkgs.writeShellScriptBin "mount-cartridge" ''
    PART="/dev/$1"
    MOUNTPOINT="/mnt/cartridge"
    LOGGER="${pkgs.util-linux}/bin/logger"

    ${pkgs.coreutils}/bin/mkdir -p $MOUNTPOINT
    while [ ! -b "$PART" ]; do sleep 0.1; done
    $LOGGER -t bbos "Cartridge found, mounting"
    ${pkgs.util-linux}/bin/mount "$PART" $MOUNTPOINT || { $LOGGER -t bbos "Mount failed"; exit 1; }
  '';

  unmountCartridge = pkgs.writeShellScriptBin "unmount-cartridge" ''
    LOGGER="${pkgs.util-linux}/bin/logger"

    $LOGGER -t bbos "Unmounting Cartridge"
    ${pkgs.util-linux}/bin/umount ${cartMount} || $LOGGER -t bbos "Unmount failed"
  '';
in
{
  imports = [
    ../../users/bbuser.nix
  ];
  home-manager.users.bbuser = import "${flake-inputs.self}/system/home/users/${kioskUser}.nix";
  services.getty.autologinUser = "${kioskUser}";

  # Maybe make each its own config file if we have to
  environment.systemPackages = [
    pkgs.sway
    pkgs.udisks2
    pkgs.mpv

    mountCartridge
    unmountCartridge
  ];

  environment.etc."bbos/whitelist.txt".source = whitelistFile;
  environment.etc."bbos/attract.mp4".source = "${flake-inputs.self}/assets/attract.mp4";

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]", TAG+="systemd", ENV{SYSTEMD_WANTS}="kiosk-mount@%k.service"
    ACTION=="remove", SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]", TAG+="systemd", ENV{SYSTEMD_WANTS}="kiosk-unmount@%k.service"
  '';

  systemd.services."kiosk-mount@" = {
    description = "Mount USB cartridge %i";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = 0;
      ExecStart = "${pkgs.bash}/bin/bash -c '${mountCartridge}/bin/mount-cartridge %i'";
    };
  };

  systemd.services."kiosk-unmount@" = {
    description = "Unmount USB cartridge %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${unmountCartridge}/bin/unmount-cartridge %i'";
    };
  };
}
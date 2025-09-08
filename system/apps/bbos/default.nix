{
  pkgs,
  lib,
  config,
  flake-inputs,
  ...
}:
let
  kioskUser = "bbuser";

  allowedRuntimes = {
    scummvm = pkgs.scummvm;
    dosbox = pkgs.dosbox;
    ecwolf = pkgs.ecwolf
  };

  whitelistFile = pkgs.writeText "kiosk-whitelist" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: pkg: "${name}=${pkg}/bin/${name}") allowedRuntimes
    )
  );

  usbLaunchScript = pkgs.writeShellScriptBin "usb-launch" ''
    #!/usr/bin/env bash
    DEVICE="/dev/$1"
    MOUNTPOINT="/mnt/cartridge"
    PIDFILE="/run/usb-launch-\$\{1\}.pid"
    WHITELIST="/etc/kiosk/whitelist.txt"

    mkdir -p "$MOUNTPOINT"
    mount "$DEVICE" "$MOUNTPOINT"

    CONFIG="$MOUNTPOINT/cart.ini"

    if [ -f "$CONFIG" ]; then
        echo "Game cartridge detected: reading configuration..."

        # Parse INI
        PROGRAM_ALIAS=$(grep '^program=' "$CONFIG" | cut -d'=' -f2- | tr -d ' ')
        PROGRAM_CMD=$(grep '^program=' "$CONFIG" | cut -d'=' -f2- | tr -d ' ')
        ARGS=$(grep '^args=' "$CONFIG" | cut -d'=' -f2-)

        # Look up alias in whitelist (Nix store paths)
        PROGRAM=$(grep "^\$\{PROGRAM_ALIAS\}=" "$WHITELIST" | cut -d'=' -f2-)
        if [ -z "$PROGRAM" ]; then
            echo "Error: Program '$PROGRAM_ALIAS' not in whitelist!"
        else
            if [ -z "$PROGRAM_CMD" ]
              eval "$PROGRAM_CMD"
            fi
            echo "Launching $PROGRAM with args: $ARGS"
            sudo -u ${kioskUser} "$PROGRAM" $ARGS &
            echo $! > "$PIDFILE"
        fi
    fi

    umount "$MOUNTPOINT"
  '';

  usbRemoveScript = pkgs.writeShellScriptBin "usb-remove" ''
    #!/usr/bin/env bash
    DEVICE="$1"
    PIDFILE="/run/usb-launch-\$\{DEVICE\}.pid"

    # Kill the game if running
    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")
        echo "USB removed: killing PID $PID"
        kill "$PID" || true
        rm "$PIDFILE"
    fi
  '';
in
{
  imports = [
    ../../users/bbuser.nix
  ];
  home-manager.users.bbuser = import "${flake-inputs.self}/system/home/users/${kioskUser}.nix";
  services.getty.autologinUser = "${kioskUser}";

  # Maybe make each its own config file if we have to
  environment.systemPackages = with pkgs; [
    sway
    udisks2
    mpv
    usbLaunchScript
    usbRemoveScript
  ];

  environment.etc."bbos/whitelist.txt".source = whitelistFile;
  environment.etc."bbos/attract.mp4".source = "${flake-inputs.self}/assets/attract.mp4";

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[b-z][0-9]", RUN+="${usbLaunchScript} %k"
    ACTION=="remove", SUBSYSTEM=="block", KERNEL=="sd[b-z][0-9]", RUN+="${usbRemoveScript} %k"
  '';
}
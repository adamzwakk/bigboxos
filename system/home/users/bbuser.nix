{ pkgs, config, lib, ... }: 
let
  cartMount = "/mnt/cartridge";

  watchCartridgeScript = pkgs.writeText "watch-cartridge.sh" ''
    #!/usr/bin/env bash
    set -euo pipefail

    MOUNTPOINT="${cartMount}"
    WHITELIST="/etc/bbos/whitelist.txt"
    KIOSK_USER="bbuser"
    PIDFILE="/run/user/$UID/cartridge.pid"

    while true; do
      CONFIG="$MOUNTPOINT/cart.ini"

      if [ -f "$CONFIG" ]; then
          # Cartridge inserted
          if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE") 2>/dev/null; then
              echo "Game cartridge detected: reading configuration..."

              PROGRAM_ALIAS=$(grep -E '^program=' "$CONFIG" | head -n1 | cut -d'=' -f2- | tr -d ' ')
              CMD=$(grep -E '^cmd=' "$CONFIG" | head -n1 | cut -d'=' -f2-)
              ARGS=$(grep -E '^args=' "$CONFIG" | head -n1 | cut -d'=' -f2- || true)

              cd "$MOUNTPOINT/files"

              if [ -n "$CMD" ]; then
                  echo "Running custom command from INI: $CMD"
                  swaymsg exec "bash -c '$CMD $ARGS'" &
              else
                  PROGRAM=$(grep "^$PROGRAM_ALIAS=" "$WHITELIST" | head -n1 | cut -d'=' -f2- || true)
                  if [ -z "$PROGRAM" ]; then
                      echo "Error: Program '$PROGRAM_ALIAS' not in whitelist!" >&2
                  else
                      echo "Launching $PROGRAM with args: $ARGS"
                      $PROGRAM "$ARGS" &
                  fi
              fi

              echo $! > "$PIDFILE"
          fi
      else
          # Cartridge removed: kill process if running
          if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
              echo "Cartridge removed: killing process $(cat "$PIDFILE")"
              kill $(cat "$PIDFILE") || true
              rm "$PIDFILE"
          fi
      fi

      sleep 1
    done
  '';
in
{

  imports = [
    ../default.nix
  ];

  programs.bash = {
    enable = true;

    initExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec sway
      fi
    '';
  };

  home.file."/.local/bin/bbos/watch-cartridge.sh" = {
    source = watchCartridgeScript;
    executable = true;
  };
 
  programs.foot = {
    enable = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      bars = [];
      window.commands = [
        {
          criteria.app_id = "mpv";
          command = "focus disable";
        }
      ];
      startup = [
        {command = "~/.local/bin/bbos/watch-cartridge.sh";}
        # {command = "${pkgs.foot}/bin/foot";}
        # {command = "${pkgs.mpv}/bin/mpv --fs --loop --osc=no --osd-bar=no --really-quiet /etc/bbos/attract.mp4";}
      ];
    };
  };

  home.stateVersion = "25.05";
}

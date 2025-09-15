{ pkgs, config, lib, ... }: 
let
  cartMount = "/mnt/cartridge";

  watchCartridgeScript = pkgs.writeText "watch-cartridge.sh" ''
    #!/usr/bin/env bash
    set -euo pipefail

    MOUNTPOINT="${cartMount}"
    WHITELIST="/etc/bbos/whitelist.txt"
    PIDFILE="/run/user/$UID/cartridge.pid"

    while true; do
      CONFIG="$MOUNTPOINT/cart.ini"

      if [ -f "$CONFIG" ]; then
          # Cartridge inserted
          if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE") 2>/dev/null; then
              echo "Game cartridge detected: reading configuration..."

              RUNTIME=$(grep -E '^runtime=' "$CONFIG" | head -n1 | cut -d'=' -f2- | tr -d ' ')
              CMD=$(grep -E '^cmd=' "$CONFIG" | head -n1 | cut -d'=' -f2-)
              ARGS=$(grep -E '^args=' "$CONFIG" | head -n1 | cut -d'=' -f2- || true)

              cd "$MOUNTPOINT/files"

              if [ -n "$CMD" ]; then
                  echo "Running custom command from INI: $CMD"
                  "$CMD $ARGS" &
              else
                  PROGRAM=$(grep "^$RUNTIME=" "$WHITELIST" | head -n1 | cut -d'=' -f2- || true)
                  if [ -z "$PROGRAM" ]; then
                      echo "Error: Program '$RUNTIME' not in whitelist!" >&2
                  else
                      echo "Launching $PROGRAM $ARGS"
                      $PROGRAM $ARGS &
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
  home.file."/.local/bin/bbos/watch-cartridge.sh" = {
    source = watchCartridgeScript;
    executable = true;
  };
}
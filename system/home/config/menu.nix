{ pkgs, config, lib, ...}:
let

  launcherScript = pkgs.writeText "launcher" ''
    #!/usr/bin/env bash
    set -euo pipefail

    MENU="/home/bbuser/.local/bin/bbos/menu.py"
    PLAY="/home/bbuser/.local/bin/bbos/play.py"

    while true; do
        # run menu inside a terminal so npyscreen can display
        foot -e python3 "$MENU"

        # check if user picked Play Cartridge
        if [ -f /tmp/bbos_play_game ]; then
            rm /tmp/bbos_play_game
            python3 "$PLAY"  # launch the game and block
            # After game exits, loop back to menu
        else
            break  # user quit menu, stop launcher
        fi
    done

  '';

in
{
  home.file."/.local/bin/bbos/menu.py" = {
    source = ./scripts/menu.py;
    executable = true;
  };

  home.file."/.local/bin/bbos/play.py" = {
    source = ./scripts/play.py;
    executable = true;
  };

  home.file."/.local/bin/bbos/launcher.sh" = {
    source = launcherScript;
    executable = true;
  };
}
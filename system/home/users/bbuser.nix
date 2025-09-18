{ pkgs, config, lib, ... }: 
{

  imports = [
    ../default.nix
    ../config/menu.nix
    ../config/runtimes
  ];

  programs.bash = {
    enable = true;

    initExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec sway
      fi
    '';
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
        {
          criteria.title = "BBOSMenu";
          command = "move to workspace 1, fullscreen enable, workspace 1";
        }
      ];
      startup = [
        {command = "~/.local/bin/bbos/launcher.sh";}
        # {command = "${pkgs.foot}/bin/foot";} ## Using this to debug/run the above manually
        # {command = "${pkgs.mpv}/bin/mpv --fs --loop --osc=no --osd-bar=no --really-quiet /etc/bbos/attract.mp4";}
      ];
    };
  };

  home.stateVersion = "25.05";
}

{ pkgs, config, lib, ... }: {

  imports = [
    ../default.nix
  ];

  programs.bash = {
    enable = true;

    # initExtra = ''
    #   if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    #       exec sway
    #   fi
    # '';
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      bars = [];
      window.commands = [
        {
          command = "focus disable";
          criteria = {
            app_id = "mpv";
          };
        }
      ];
      startup = [
        # {command = "mpv --fs --loop --osc=no --osd-bar=no --really-quiet /etc/bbos/attract.mp4";}
      ];
    };
  };

  home.stateVersion = "25.05";
}

{
  config,
  pkgs,
  lib,
  flake-inputs,
  ...
}:
{
  imports = [
    flake-inputs.home-manager.nixosModules.home-manager
    ./services/networking/iwd.nix
    ./services/networking/networkmanager.nix

    ./apps/bbos
    ./apps/runtimes      # Runtimes are always global

    ./users/bbadmin.nix

    ./hardware-configuration.nix
  ];

  nix = {
    package = pkgs.nixVersions.latest;

    gc = {
      options = "--delete-older-than 30d";
      dates = "daily";
      automatic = true;
    };

    settings = {
      trusted-users = ["bbadmin"];
      sandbox = "relaxed";
      auto-optimise-store = true;
      allowed-users = ["bbadmin"];             # My god it took me hours to realize you need the user here for home manager to work
      experimental-features = "nix-command flakes";
      http-connections = 50;
      warn-dirty = false;
      log-lines = 50;
    };
  };
  
  nixpkgs = {
    config.allowUnfree = true;
  };

  boot = {
    tmp.cleanOnBoot = true;
    kernelModules = [ "kvm-amd" "sg"];
    kernel.sysctl = { "vm.swappiness" = 20; };
    kernelPackages = pkgs.linuxPackages_zen;

    loader = {
      grub.enable = true;
      grub.devices = [ "$BOOT_DEVICE" ];
      grub.efiSupport = true;
      grub.efiInstallAsRemovable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };

  };

  time.timeZone = lib.mkDefault "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit flake-inputs;
      nmEnabled = config.networking.networkmanager.enable;  # Determine if we're using nm or not
    };
  };

  users.defaultUserShell = pkgs.bash;
  fileSystems."/boot".options = [ "fmask=0077" "dmask=0077" ];

  fonts = {
    #enableDefaultPackages = true;
    fontDir = {
      enable = true;
    };
    fontconfig = {
      enable = true;
    };
    packages = with pkgs; [
      noto-fonts
    ];
  };

  # My systems never have usable root accounts anyway, so emergency
  # mode just drops into a shell telling me it can't log into root
  systemd.enableEmergencyMode = false;

  security.rtkit.enable = true;

  services = {
    pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    udisks2.enable = true;
    automatic-timezoned.enable = true;
  };

  hardware.enableRedistributableFirmware = true;

  networking.firewall.enable = true;

  environment = {
    systemPackages = with pkgs; [
      nano
      git
      openssl
      nh
      wget
      rar
      pavucontrol
      brightnessctl        # Screen/laptop brightness
      killall
      p7zip
      fzf                  # Fuzzy Finder

      htop
      fastfetch            # System stats fetching
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb
    ];

    sessionVariables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      # To prevent firefox from creating ~/Desktop.
      XDG_DESKTOP_DIR = "$HOME";
      EDITOR = "nano";
      BROWSER = "firefox";
      TERMINAL = "alacritty";

      NIXOS_OZONE_WL = "1";
    };
    variables = {
      # Make some programs "XDG" compliant.
      LESSHISTFILE = "$XDG_CACHE_HOME/less/history";
      LESSKEY = "$XDG_CACHE_HOME/less/lesskey";
      WGETRC = "$XDG_CONFIG_HOME/wgetrc";
    };
  };


  system.stateVersion = "25.05";
}
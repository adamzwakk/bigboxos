# BigBoxOS

An OS based on NixOS to run custom cartridge games as an appliance

## Getting Started

Within an existing NisOX environment, build the ISO with `nix build .#nixosConfigurations.installer.config.system.build.isoImage`

Or run the installed OS as a temp VM with `nixos-rebuild build-vm --flake .#bbos && ./result/bin/run-bbos-vm -monitor stdio`
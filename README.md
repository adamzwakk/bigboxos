# BigBoxOS

An OS based on NixOS to run custom cartridge games as an appliance. Idea is anyone can make 'cartridges' and create games for a centralized system. Using a combination of source ports, DOSBox, Wine, Proton, whatever we can find to make games portable and as 'plug and play' as possible.

Lets make physical games cool and big again!


## Structure

```
assets          -- jpgs/mp4s
installer       -- installer env
system          -- installed system env
tools           -- scripts/tools to make your own content
```

## Getting Started

Within an existing NisOX environment, build the ISO with `nix build .#nixosConfigurations.installer.config.system.build.isoImage`

Or run the installed OS as a temp VM with `nixos-rebuild build-vm --flake .#bbos && ./result/bin/run-bbos-vm -monitor stdio`

## But does this actually do anything yet?

Well... no, but I'm hoping to get a couple running examples going soon, either converting existing DOSBox configs or reverse engineering GOG installs and providing the tooling to DIY.
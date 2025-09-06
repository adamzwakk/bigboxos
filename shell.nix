{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "installer-build-shell";

  buildInputs = [
    pkgs.qemu_kvm          # QEMU with KVM support
    pkgs.dialog            # Mostly so I can test menus
  ];
}
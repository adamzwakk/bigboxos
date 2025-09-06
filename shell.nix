{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "installer-test-shell";

  buildInputs = [
    pkgs.qemu_kvm          # QEMU with KVM support
    pkgs.git                # version control, optional
    pkgs.dialog             # TUI menus for testing
    pkgs.gum                # pretty TUI prompts
    pkgs.jq                 # JSON processing
    pkgs.bash               # ensure bash is available
    pkgs.parted             # for testing partition commands
    pkgs.e2fsprogs          # mkfs.ext4 and related
    pkgs.util-linux         # lsblk, mount, blkid
  ];
}
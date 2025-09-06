{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "installer-build-shell";

  buildInputs = with pkgs; [
    qemu_kvm          # QEMU with KVM support
    dialog            # Mostly so I can test menus
    OVMF
  ];

  shellHook = ''

    start_installer_vm() {
      qemu-system-x86_64 \
        -enable-kvm \
        -m 4G \
        -cdrom ./result/iso/*.iso \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        -drive file=testdisk.qcow2,format=qcow2,if=virtio \
        -boot d
    };

    start_hdd_vm() {
      qemu-system-x86_64 \
        -enable-kvm \
        -m 4G \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        -drive file=testdisk.qcow2,format=qcow2,if=virtio \
        -boot d
    }
  '';
}
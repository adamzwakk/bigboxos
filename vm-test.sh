nix build .#nixosConfigurations.installer.config.system.build.isoImage && \
rm testdisk.qcow2 || true && \
qemu-img create -f qcow2 testdisk.qcow2 10G && \
qemu-system-x86_64 \
  -enable-kvm \
  -m 2G \
  -cdrom ./result/iso/*.iso \
  -drive file=testdisk.qcow2,format=qcow2,if=virtio \
  -boot d
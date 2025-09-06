nix build .#nixosConfigurations.installer.config.system.build.isoImage && \
rm testdisk.qcow2 || true && \
qemu-img create -f qcow2 testdisk.qcow2 10G && \
echo "Run start_vm to boot this puppy"
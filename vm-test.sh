nix build .#nixosConfigurations.installer.config.system.build.isoImage && \
rm testdisk.qcow2 || true && \
qemu-img create -f qcow2 testdisk.qcow2 50G && \
echo "Run start_installer_vm or start_hdd_vm to boot this puppy"
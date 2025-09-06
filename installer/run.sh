set -euo pipefail

# --- Ensure running as root ---
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

# --- List available disks ---
DISK_MENU=()
while read -r name size type; do
  if [ "$type" = "disk" ]; then
    DISK_MENU+=("/dev/$name" "$name ($size)")
  fi
done < <(lsblk -ndo NAME,SIZE,TYPE)

if [ ${#DISK_MENU[@]} -eq 0 ]; then
  echo "No disks detected!"
  exit 1
fi

GREETING=$(dialog --stdout --title "BBBOS Installer" --menu "Weclome to the BigBoxOS Installer" 15 50 5 "Continue" "Install to Disk" "Exit" "Get outta here")

if [ "$GREETING" == "Exit" ] || [ -n "$GREETING"]; then
    clear
    echo "Idk what you expected but get out/reboot"; exit 1;
fi

DISK=$(dialog --stdout \
  --title "Select installation disk" \
  --menu "Choose the target disk:" 15 50 5 \
  "${DISK_MENU[@]}")

[ -n "$DISK" ] || { echo "No disk selected, exiting."; exit 1; }

# --- Confirm erase ---
dialog --yesno "WARNING: This will ERASE ALL DATA on $DISK. Continue?" 10 50 || exit 1

# --- Partitioning (UEFI aware) ---
UEFI_BOOT=0
if [ -d /sys/firmware/efi ]; then
  UEFI_BOOT=1
fi

# Wipe disk
sgdisk --zap-all "$DISK"

if [ "$UEFI_BOOT" -eq 1 ]; then
  parted --script "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 boot on \
    mkpart nixos ext4 513MiB 100%
else
  parted --script "$DISK" mklabel gpt mkpart nixos ext4 1MiB 100%
fi

partprobe "$DISK"
udevadm settle

# --- Format partitions ---
if [ "$UEFI_BOOT" -eq 1 ]; then
  mkfs.fat -F32 /dev/disk/by-partlabel/ESP
fi
mkfs.ext4 -L nixos /dev/disk/by-partlabel/nixos

udevadm settle

# --- Mount ---
mount /dev/disk/by-label/nixos /mnt
if [ "$UEFI_BOOT" -eq 1 ]; then
  mkdir -p /mnt/boot
  mount /dev/disk/by-partlabel/ESP /mnt/boot
fi

# --- Generate NixOS config ---
nixos-generate-config --root /mnt

cp -r /etc/installer/src/* /mnt/etc/nixos/
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/system/hardware-configuration.nix

# --- Install from baked flake ---
nixos-install --flake /mnt/etc/nixos#bbos

dialog --msgbox "Installation complete! Reboot now." 10 40

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

### GET DISK INFO ###
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

dialog --yesno "WARNING: This will ERASE ALL DATA on $DISK. Continue?" 10 50 || exit 1

### ERASE/PARTITION DISKS ###

sgdisk --zap-all "$DISK"

ROOT_SIZE=30GiB

parted --script "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 boot on \
    mkpart nixos ext4 513MiB "$ROOT_SIZE" \
    mkpart home ext4 "$ROOT_SIZE" 100%

partprobe "$DISK"
udevadm settle

# --- Format partitions ---
mkfs.fat -F32 /dev/disk/by-partlabel/ESP
mkfs.ext4 -L nixos /dev/disk/by-partlabel/nixos
mkfs.ext4 -L home /dev/disk/by-partlabel/home

udevadm settle

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-partlabel/ESP /mnt/boot
mkdir -p /mnt/home
mount /dev/disk/by-label/home /mnt/home

nixos-generate-config --root /mnt

cp -r /etc/installer/src/* /mnt/etc/nixos/
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/system/hardware-configuration.nix

nixos-install --flake /mnt/etc/nixos#bbos

dialog --msgbox "Installation complete! I'm gonna reboot when you say so." 10 40
reboot

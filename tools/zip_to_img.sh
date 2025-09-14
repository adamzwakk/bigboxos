SHORT_NAME="$1"
IMG_NAME="$1.img"
IMG_PATH="./dist/$IMG_NAME"
ZIP_PATH="./dist/$SHORT_NAME.zip"
MOUNTPOINT="./tmp_usb"

if [ ! -f "$ZIP_PATH" ]; then
    echo "Source zip not found!"
    exit 1
fi

# Create 2G raw image
qemu-img create -f raw "$IMG_PATH" 2G

# Map image to a free loop device
LOOP=$(sudo losetup -f --show "$IMG_PATH")

# Create a single partition (GPT) covering entire image
sudo parted "$LOOP" --script mklabel gpt
sudo parted "$LOOP" --script mkpart primary 1MiB 100%

# Refresh loop device mapping (partition becomes /dev/loopXp1)
sudo partprobe "$LOOP"
PARTITION="${LOOP}p1"

# Format partition as exFAT
sudo mkfs.exfat -n CARTRIDGE "$PARTITION"

# Mount, copy contents
mkdir -p "$MOUNTPOINT"
sudo mount "$PARTITION" "$MOUNTPOINT"
sudo chmod -R 777 "$MOUNTPOINT"
sudo unzip -qq "$ZIP_PATH" -d "$MOUNTPOINT"

# Unmount and detach loop
sudo umount "$MOUNTPOINT"
sudo losetup -d "$LOOP"
rm -rf "$MOUNTPOINT"

echo "Image ready: $IMG_PATH"
echo "Add to QEMU with:"
echo "drive_add 0 id=usbdisk,file=$(realpath $IMG_PATH),format=raw,if=none"
echo "device_add usb-storage,drive=usbdisk"
SHORT_NAME="$1"
IMG_NAME="$1.img"

qemu-img create -f raw "./dist/$IMG_NAME" 2G
mkfs.exfat "./dist/$IMG_NAME"

mkdir ./tmp_usb
sudo mount -o loop "./dist/$IMG_NAME" ./tmp_usb
sudo chmod -R 777 ./tmp_usb
sudo unzip -qq ./dist/$SHORT_NAME.zip -d ./tmp_usb
sudo umount ./tmp_usb
rm -r ./tmp_usb

echo ""
echo "Add the img to the QEMU monitor with 'drive_add 0 id=usbdisk,file=$(realpath ./dist/$IMG_NAME),format=raw,if=none'"
echo "Followed by 'device_add usb-storage,drive=usbdisk' to plug it in"
#!/usr/bin/env bash
# usage: ./sd_burner.sh /dev/sdc
# stop on errors
set -eu

# Check if user is root or sudo
if ! [ $( id -u ) = 0 ]; then
    echo "Please run this script as sudo or root" 1>&2
    exit 1
fi

DEFAULT_PARTITION=/dev/mmcblk0
if [ "$1" ]; then
  echo "Chose SD partition: $1"
  DEFAULT_PARTITION=$1
else
  echo "No user argument using default value: ${DEFAULT_PARTITION}"
fi

# Export settings
export SDDEV=${DEFAULT_PARTITION}
export SDPARTBOOT=${SDDEV}p1
export SDPARTROOT=${SDDEV}p2
export SDMOUNT=/mnt/sd
export DOWNLOADDIR=/tmp/pi
echo -e -n "Settings:\nSDDEV=${SDDEV}\nBOOT=${SDPARTBOOT}\nROOT=${SDPARTROOT}\nSDMOUNT=${SDMOUNT}\nDOWNLOADDIR=${DOWNLOADDIR}\n"

# Download. Never cache.
mkdir -p $DOWNLOADDIR
(
  cd $DOWNLOADDIR #&& \
  curl -JLO http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
  echo -e "[+] Download  ArchLinuxARM-rpi-aarch64-latest.tar.gz"
)

# Clean disk
sfdisk --quiet --wipe always $SDDEV << EOF
,400M,0c,
,,,
EOF
# Format disk
echo -e "[+] fdisk ${DEFAULT_PARTITION}"

mkfs.vfat -F 32 $SDPARTBOOT
echo -e  "[+] mkfs.vfat ${SDPARTBOOT}"

#mkfs.ext4 -q -E lazy_itable_init=0,lazy_journal_init=0 -F $SDPARTROOT
mkfs.ext4  -F $SDPARTROOT
echo -e  "[+] mkfs.ext4 ${SDPARTROOT}"

# Mount partitions

mkdir -p $SDMOUNT
mount $SDPARTROOT $SDMOUNT
mkdir -p ${SDMOUNT}/boot
mount $SDPARTBOOT ${SDMOUNT}/boot
echo -e "[+] mount"

# Extract into SD
bsdtar -xpf ${DOWNLOADDIR}/ArchLinuxARM-rpi-aarch64-latest.tar.gz -C $SDMOUNT
echo -e "[+] extract  ${DOWNLOADDIR}/ArchLinuxARM-rpi-aarch64-latest.tar.gz"

# Change fstab
#echo -e "set fstab"
#sed -i 's/mmcblk0/mmcblk1/g' ${SDMOUNT}/etc/fstab

## mmc1: unreconized SCR structure version 4
sed -i 's/{fdt_addr_r};/{fdt_addr};/g' ${SDMOUNT}/boot/boot.txt
pushd ${SDMOUNT}/boot
./mkscr
popd
echo -e "[+] Edit boot.txt and generate boot.scr"

#echo "hdmi_force_hotplug=1" >> ${SDMOUNT}/boot/config.txt
#echo "hdmi_group=2" >> ${SDMOUNT}/boot/config.txt
#echo "hdmi_mode=82" >> ${SDMOUNT}/boot/config.txt
sed -i "s/^#PubkeyAuthentication.*/PubkeyAuthentication yes/g" ${SDMOUNT}/etc/ssh/sshd_config
echo "PermitRootLogin yes" >> ${SDMOUNT}/etc/ssh/sshd_config
/usr/bin/install --directory --owner=jubeaz --group=jubeaz --mode=0700 ${SDMOUNT}/home/alarm/.ssh
/usr/bin/install --owner=jubeaz --group=jubeaz --mode=0600  /home/jubeaz/.ssh/authorized_keys ${SDMOUNT}/home/alarm/.ssh/authorized_keys
/usr/bin/install --owner=root --group=root --mode=0700  init.sh ${SDMOUNT}/root/init.sh
echo -e "[+] Setup sshd"

# Sync and Umount
sync
echo -e "[+] Sync"
umount -R $SDMOUNT
echo -e "[+] umount"
echo -e "Done"

#!/usr/bin/env bash
# usage: ./sd_burner.sh /dev/sdc
# stop on errors
set -eu

# Check if user is root or sudo
if ! [ $( id -u ) = 0 ]; then
    echo "Please run this script as sudo or root" 1>&2
    exit 1
fi

DEFAULT_PARTITION=/dev/nvme0n1
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
  #curl -JLO http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
)

# Clean disk
sfdisk --quiet --wipe always $SDDEV << EOF
,400M,0c,
,,,
EOF
# Format disk
mkfs.vfat -F 32 $SDPARTBOOT
mkfs.ext4 -q -E lazy_itable_init=0,lazy_journal_init=0 -F $SDPARTROOT

# Mount partitions
mkdir -p $SDMOUNT
mount $SDPARTROOT $SDMOUNT
mkdir -p ${SDMOUNT}/boot
mount $SDPARTBOOT ${SDMOUNT}/boot

# Extract into SD
bsdtar -xpf ${DOWNLOADDIR}/ArchLinuxARM-rpi-aarch64-latest.tar.gz -C $SDMOUNT

# Change fstab
sed -i 's/mmcblk0/mmcblk1/g' ${SDMOUNT}/etc/fstab

sed -i "s/^#PubkeyAuthentication/PubkeyAuthentication yes/g" ${SDMOUNT}/etc/ssh/sshd_config
echo "PermitRootLogin yes" >> ${SDMOUNT}/etc/ssh/sshd_config
/usr/bin/install --directory --owner=jubeaz --group=jubeaz --mode=0700 ${SDMOUNT}/home/alarm/.ssh
/usr/bin/install --owner=jubeaz --group=jubeaz --mode=0600  /home/jubeaz/.ssh/authorized_keys ${SDMOUNT}/home/alarm/.ssh/authorized_keys
/usr/bin/install --owner=root --group=root --mode=0700  init.sh ${SDMOUNT}/root/init.sh


# Sync and Umount
sync
umount -R $SDMOUNT
#!/usr/bin/env bash
set -eu

packer() {
    export DISK=/dev/sda
    export VG=vg0
    export HAS_SWAP='true'
    export SWAP_LV="/dev/${VG}/swap"
    export IS_ENCRYPTED='false'
    export ENCRYPT_PART=''
    export ENCRYPT_VG=''
    export ENCRYPT_LV_ROOT=''
    export WITH_WIFI="false"
    export IS_UEFI='true'
    export IS_UEFI_REMOVABLE='true'
    export GRUB_PART="${DISK}1"

    export ADDITIONAL_PKGS=""
    export DOMAINE_NAME="local"
    export ANSIBLE_LOGIN="jubeaz"
    export ANSIBLE_PASSWORD="jubeaz"
    export KEYMAP="fr-latin1"
    export LOCALE="fr_FR.UTF-8"
    export COUNTRIES="Fance,Germany"

    ! mountpoint -q /mnt || umount -R /mnt

    echo ">>>> prepae.sh: zeroing..."
    dd if=/dev/zero of=${DISK} bs=1k count=2048 

    parted ${DISK} --script mklabel gpt
    parted -a optimal ${DISK} --script mkpart ESP fat32 1MiB 1025MiB
    parted -a optimal ${DISK} --script set 1 esp on
    parted -a optimal ${DISK} --script mkpart primary ext4 1025MiB 100%
    parted -a optimal ${DISK} --script set 2 lvm on
    parted -s ${DISK} align-check optimal 1

    pvcreate ${DISK}2
    vgcreate ${VG} ${DISK}2
    lvcreate -C y -L 4G ${VG} -n swap
    lvcreate -L 1G} ${VG} -n boot
    lvcreate -l 100%FREE ${VG} -n root
    mkswap /dev/${VG}/swap
    mkfs.ext4 /dev/${VG}/boot
    mkfs.ext4 /dev/${VG}/root
    modprobe dm_mod
    vgscan
    vgchange -ay

    mount /dev/${VG}/root /mnt
    mkdir /mnt/boot
    mount /dev/${VG}/boot /mnt/boot
}

if [ "$1" == "--packer" ];then
        packer
else
	echo ">>>> prepae.sh: Error unknown host..."
fi
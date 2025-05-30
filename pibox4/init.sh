#!/usr/bin/env bash
# usage: ./sd_burner.sh /dev/sdc
# stop on errors
set -eu

pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu
yes | pacman -S  linux-rpi linux-rpi-headers
yes | pacman -S --noconfirm sudo python vim bash-completion raspberrypi-utils firmware-raspberrypi


echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/jubeaz
echo 'jubeaz ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/jubeaz
/usr/bin/chmod 0440 /etc/sudoers.d/jubeaz
# rename alarm into jubeaz and move home
usermod -l jubeaz alarm
usermod -d /home/jubeaz -m jubeaz
groupmod -n jubeaz alarm

# disable root
sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config
passwd -l root
reboot

#!/usr/bin/env bash

# stop on errors
set -eu
HOSTNAME=""

. /root/private/secrets.sh --${HOSTNAME}
DOMAINE_NAME=${DOMAINE_NAME:-"local"}
KEYMAP=${KEYMAP:-'fr-latin1'}
LANGUAGE=${LANGUAGE:-'en_US.UTF-8'}
COUNTRIES=${COUNTRIES:-France,Germany}
ADDITIONAL_PKGS=${ADDITIONAL_PKGS:-"vim python python-cryptography"}
ANSIBLE_LOGIN=${ANSIBLE_LOGIN:-"ansible"}
ANSIBLE_PASSWORD=${ANSIBLE_PASSWORD:-"ansible_P1"}
IS_CRYPTED=${IS_CRYPTED:-"false"}
BASE_PKGS="gptfdisk rng-tools reflector lsof bash-completion openssh rsync netplan ufw apparmor firejail libpwquality rkhunter arch-audit man-db mlocate pacman-contrib ansible"
if [ "${WITH_WIFI}" == "true" ] ; then
  BASE_PKGS="${BASE_PKGS} iwd wireless_tools"
fi
GRUB_PKGS="grub dosfstools os-prober mtools"
if [ "${IS_UEFI}" != "false" ] ; then
  GRUB_PKGS="${GRUB_PKGS} efibootmgr"
fi
GRUB_CMDLINE_STR="net.ifnames=0 biosdevname=0"
if [ "${IS_ENCRYPTED}" != "false" ] ; then
   ENCRYPT_UUID=$(blkid | grep ${ENCRYPT_PART} | cut -d'"' -f 2)
   CMD_LINE_STR="net.ifnames=0 biosdevname=0 cryptdevice=UUID=${ENCRYPT_UUID}:cryptlvm root=/dev/${ENCRYPT_VG}/${ENCRYPT_LV_ROOT} cryptkey=rootfs:/root/secrets/cryptlvm.keyfile"
fi

echo ">>>>>>>>>>>>>>>> ${HOSTNAME}"
echo ">>>>>>>>>>>>>>>> ${COUNTRIES}"
echo ">>>>>>>>>>>>>>>> ${KEYMAP}"
echo ">>>>>>>>>>>>>>>> ${LANGUAGE}"
echo ">>>>>>>>>>>>>>>> $WITH_WIFI"
echo ">>>>>>>>>>>>>>>> $ADDITIONAL_PKGS"
echo ">>>>>>>>>>>>>>>> $IS_UEFI"
echo ">>>>>>>>>>>>>>>> $GRUB_PART"
echo ">>>>>>>>>>>>>>>> $IS_UEFI_REMOVABLE"
echo ">>>>>>>>>>>>>>>> $IS_ENCRYPTED"

TIMEZONE='UTC'
CONFIG_SCRIPT='/usr/local/bin/arch-config.sh'
TARGET_DIR='/mnt'


# #######################################
#
#
#
# #######################################

echo ">>>> install-base.sh: Setting pacman ${COUNTRIES} mirrors.."
/usr/bin/reflector --verbose  --country ${COUNTRIES} --latest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo ">>>> install-base.sh: Bootstrapping the base installation.."
/usr/bin/pacstrap ${TARGET_DIR} base base-devel linux-lts linux-lts-headers linux-firmware lvm2

echo ">>>> install-base.sh: Copy mirror list.."
/usr/bin/cp /etc/pacman.d/mirrorlist "${TARGET_DIR}/etc/pacman.d"


echo ">>>> install-base.sh: Generating the filesystem table.."
/usr/bin/genfstab -U -p ${TARGET_DIR} >> "${TARGET_DIR}/etc/fstab"

echo ">>>> install-base.sh: Generating the system configuration script.."
/usr/bin/install --mode=0755 /dev/null "${TARGET_DIR}${CONFIG_SCRIPT}"

# #######################################
#
#
#
# #######################################
echo ">>>> install-base.sh: Install ansible tmp key file.."
/usr/bin/install --mode=0644 /root/.ssh/authorized_keys "${TARGET_DIR}/ansible.pub"

echo ">>>> install-base.sh: Install netplan "
mkdir -p "${TARGET_DIR}/etc/netplan"
/usr/bin/install --mode=0644 "/root/private/${HOSTNAME}.yaml" "${TARGET_DIR}/etc/netplan/${HOSTNAME}.yaml"

if [ "${WITH_WIFI}" == "true" ] ; then
  echo ">>>> install-base.sh: copy wifi networks"
  mkdir -p ${TARGET_DIR}/var/lib/iwd
  cp -rf /var/lib/iwd/* ${TARGET_DIR}/var/lib/iwd
fi

CONFIG_SCRIPT_SHORT=`basename "$CONFIG_SCRIPT"`
cat <<-EOF > "${TARGET_DIR}${CONFIG_SCRIPT}"
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring hostname, timezone, and keymap.."
  echo '${HOSTNAME}' > /etc/hostname
  echo '127.0.0.1   localhost' > /etc/hosts
  echo '127.0.1.1   ${HOSTNAME} ${HOSTNAME}.${DOMAINE_NAME}' >> /etc/hosts
  /usr/bin/ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
  echo 'KEYMAP=${KEYMAP}' > /etc/vconsole.conf

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring locale.."
  /usr/bin/sed -i 's/#${LANGUAGE}/${LANGUAGE}/' /etc/locale.gen
  /usr/bin/locale-gen
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: add lvm2 for initramfs.."
  if [ "${IS_ENCRYPTED}" != "false" ] ; then
    mkdir /root/secrets
    dd bs=512 count=4 if=/dev/random of=/root/secrets/cryptlvm.keyfile iflag=fullblock
    chmod 600 /root/secrets/cryptlvm.keyfile
    cryptsetup -v luksAddKey ${ENCRYPT_PART} /root/secrets/cryptlvm.keyfile
    /usr/bin/sed -i 's/block filesystems/block encrypt lvm2 filesystems/' /etc/mkinitcpio.conf
    /usr/bin/sed -i 's|FILES=(.*|FILES=(/root/secrets/cryptlvm.keyfile)|' /etc/mkinitcpio.conf

  else
    /usr/bin/sed -i 's/block filesystems/block lvm2 filesystems/' /etc/mkinitcpio.conf
  fi

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Creating initramfs.."
  /usr/bin/mkinitcpio -p linux-lts


# #######################################
# packages
# #######################################

  
  echo ">>>> install-base.sh: Installing basic packages.."
  pacman -S --noconfirm ${BASE_PKGS} ${GRUB_PKGS} ${ADDITIONAL_PKGS}

# #######################################
# network
# #######################################
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring network.ckup."
  # Disable systemd Predictable Network Interface Names and revert to traditional interface names
  # https://wiki.archlinux.org/index.php/Network_configuration#Revert_to_traditional_interface_names
  /usr/bin/ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

  if [ "${WITH_WIFI}" == "true" ] ; then
    systemctl enable iwd
  fi

  netplan generate
  netplan appy

  /usr/bin/systemctl enable systemd-networkd
  /usr/bin/systemctl enable systemd-resolved

# #######################################
# reflector
# #######################################
echo "" > /etc/xdg/reflector/reflector.conf
echo "--save /etc/pacman.d/mirrorlist" >> /etc/xdg/reflector/reflector.conf
echo "--protocol https" >> /etc/xdg/reflector/reflector.conf
echo "--country ${COUNTRIES}" >> /etc/xdg/reflector/reflector.conf
echo "--latest 5" >> /etc/xdg/reflector/reflector.conf
echo "--sort rate" >> /etc/xdg/reflector/reflector.conf

/usr/bin/systemctl enable reflector.service
/usr/bin/systemctl enable reflector.timer

# #######################################
# sshd
# #######################################

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring sshd.."
  /usr/bin/sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
# PubkeyAuthentication yes
# PubkeyAcceptedKeyTypes=+ssh-rsa

  /usr/bin/systemctl enable sshd.service

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Adding workaround for sshd connection issue after reboot.."
  /usr/bin/systemctl enable rngd

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: regen ssh host keys."
  rm  /etc/ssh/*.key
  rm  /etc/ssh/*_key
  ssh-keygen -A

# #######################################
# ufw
# #######################################

  systemctl enable ufw

# #######################################
# Apparmor
# #######################################

  systemctl enable apparmor

# #######################################
# Hardening
# #######################################
  /usr/bin/sed -i 's/umask 022/umask 027/' /etc/profile
  # Disable core dumps
  echo  '* hard core 0' >> /etc/security/limits.conf

  /usr/bin/sed -i 's/PASS_MAX_DAYS	99999/PASS_MAX_DAYS 183/' /etc/login.defs
  /usr/bin/sed -i 's/PASS_MAX_DAYS	0/PASS_MAX_DAYS 1/' /etc/login.defs
  /usr/bin/sed -i 's/PASS_WARN_AGE	0/PASS_WARN_AGE 15/' /etc/login.defs
  echo 'SHA_CRYPT_MIN_ROUNDS 5000' >> /etc/login.defs

  # Harden passwords 
  /usr/bin/sed -i 's/^password/#password/' /etc/pam.d/passwd
  echo 'password required pam_pwquality.so retry=2 minlen=10 difok=6 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1 [badwords=myservice mydomain] enforce_for_root' >> /etc/pam.d/passwd
  echo 'password required pam_unix.so use_authtok sha512 shadow' >> /etc/pam.d/passwd
 
  # Disable uncommon protocols
  echo "blacklist dccp" >> /etc/modprobe.d/local-dontload.conf
  echo "install dccp /bin/true" >> /etc/modprobe.d/local-dontload.conf
  echo "blacklist sctp" >> /etc/modprobe.d/local-dontload.conf
  echo "install sctp /bin/true" >> /etc/modprobe.d/local-dontload.conf
  echo "blacklist rds" >> /etc/modprobe.d/local-dontload.conf
  echo "install rds /bin/true" >> /etc/modprobe.d/local-dontload.conf
  echo "blacklist tipc" >> /etc/modprobe.d/local-dontload.conf
  echo "install tipc /bin/true" >> /etc/modprobe.d/local-dontload.conf

#  rkhunter --propupd
  
# #######################################
# Ansible user
# #######################################

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Creating ${ANSIBLE_LOGIN} user.."
  /usr/bin/useradd --comment '${ANSIBLE_LOGIN}' --create-home --user-group ${ANSIBLE_LOGIN}
  echo "${ANSIBLE_LOGIN}:${ANSIBLE_PASSWORD}" | /usr/bin/chpasswd
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring sudo.."
  echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/${ANSIBLE_LOGIN}
  echo '${ANSIBLE_LOGIN} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/${ANSIBLE_LOGIN}
  /usr/bin/chmod 0440 /etc/sudoers.d/${ANSIBLE_LOGIN}
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring ssh access for ${ANSIBLE_LOGIN}.."
  /usr/bin/install --directory --owner=${ANSIBLE_LOGIN} --group=${ANSIBLE_LOGIN} --mode=0700 /home/${ANSIBLE_LOGIN}/.ssh
  /usr/bin/install --owner=${ANSIBLE_LOGIN} --group=${ANSIBLE_LOGIN} --mode=0600 /ansible.pub /home/${ANSIBLE_LOGIN}/.ssh/authorized_keys
  rm /ansible.pub

# #######################################
# ansible
# #######################################
  rm -rf /etc/ansible 
  git -C /etc clone  https://github.com/jubeaz/jubeaz_recovery.git ansible
  chmod 740 /etc/ansible
  chown --recursive ${ANSIBLE_LOGIN}:root /etc/ansible
  rm -rf /home/${ANSIBLE_LOGIN}/.bash*
  /usr/bin/git clone --bare https://github.com/jubeaz/dotfiles.git /home/${ANSIBLE_LOGIN}/.dotfiles
  /usr/bin/git --git-dir=/home/${ANSIBLE_LOGIN}/.dotfiles/ --work-tree=/home/${ANSIBLE_LOGIN} checkout
  
  chown --recursive ${ANSIBLE_LOGIN}:${ANSIBLE_LOGIN} /home/$ANSIBLE_LOGIN}/.[a-z]*



# #######################################
# grub
# #######################################

  # allways run GRUB_CMDLINE_LINUX
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: setting grub kernel boot params"

  if [ "${IS_ENCRYPTED}" != "false" ] ; then
    /usr/bin/sed -i 's/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/'  /etc/default/grub
  fi
  /usr/bin/sed -i  '/GRUB_CMDLINE_LINUX=.*/d' /etc/default/grub
  echo 'GRUB_CMDLINE_LINUX="'${CMD_LINE_STR}'"'  >> /etc/default/grub
  # do not run in recovery GRUB_CMDLINE_LINUX_DEFAULT
  /usr/bin/sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 ipv6.disable=1 lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub

  if [ "${IS_UEFI}" != "false" ] ; then
    mkdir -p /boot/efi
    mkfs.vfat -F32 ${GRUB_PART}
    mount ${GRUB_PART} /boot/efi
    mkdir -p /boot/efi/EFI
    if [ "${IS_UEFI_REMOVABLE}" != "true" ] ; then
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub_uefi --recheck
    else
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub_uefi --removable
    fi
    mkdir -p /boot/grub/locale
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
    grub-mkconfig -o /boot/grub/grub.cfg
  else
    grub-install --target=i386-pc --recheck ${GRUB_PART}
    # mkdir /boot/grub/locale
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
    grub-mkconfig -o /boot/grub/grub.cfg
  fi
  chmod 700 /boot
# #######################################
#
# #######################################
EOF

echo ">>>> install-base.sh: Entering chroot and configuring system.."
/usr/bin/arch-chroot ${TARGET_DIR} ${CONFIG_SCRIPT}
rm "${TARGET_DIR}${CONFIG_SCRIPT}"

echo ">>>> install-base.sh: Completing installation.."
/usr/bin/sleep 3
/usr/bin/umount ${TARGET_DIR}
/usr/bin/umount -a
/usr/bin/systemctl reboot
echo ">>>> install-base.sh: Installation complete!"
echo ">>>>>>>>>>>>>>>>>> DONE >>>>>>>>>>>>>>>>>>>>"

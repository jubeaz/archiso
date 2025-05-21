#!/usr/bin/env bash

# stop on errors
set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 <computer_name>"
    exit 1
fi

HOSTNAME=$1

. /root/prepare.sh --${HOSTNAME}
DOMAINE_NAME=${DOMAINE_NAME:-"local"}
KEYMAP=${KEYMAP:-'fr-latin1'}
LOCALE=${LOCALE:-'fr_FR.UTF-8'}
COUNTRIES=${COUNTRIES:-France,Germany}
ADDITIONAL_PKGS=${ADDITIONAL_PKGS:-""}
ANSIBLE_LOGIN=${ANSIBLE_LOGIN:-"ansible"}
ANSIBLE_PASSWORD=${ANSIBLE_PASSWORD:-"ansible_P1"}
IS_ENCRYPTED=${IS_ENCRYPTED:-"false"}
HAS_SWAP=${HAS_SWAP:-"false"}
SWAP_LV=${SWAP_LV:-"false"}
ENCRYPT_PART=${ENCRYPT_PART:-"false"}


#BASE_PKGS="gptfdisk rng-tools reflector lsof bash-completion openssh rsync ufw apparmor firejail libpwquality rkhunter arch-audit man-db mlocate pacman-contrib ansible"
BASE_PKGS="gptfdisk rng-tools reflector lsof bash-completion openssh rsync ufw libpwquality mlocate pacman-contrib ansible git vim python python-cryptography"

if [ "${WITH_WIFI}" == "true" ] ; then
  BASE_PKGS="${BASE_PKGS} iwd wireless_tools wireless-regdb"
fi

GRUB_PKGS="grub dosfstools os-prober mtools"
if [ "${IS_UEFI}" != "false" ] ; then
  GRUB_PKGS="${GRUB_PKGS} efibootmgr"
fi

ENCRYPT_CMD_LINE_STR=""
if [ "${IS_ENCRYPTED}" != "false" ] ; then
   ENCRYPT_UUID=$(blkid | grep ${ENCRYPT_PART} | cut -d'"' -f 2)
   ENCRYPT_CMD_LINE_STR="cryptdevice=UUID=${ENCRYPT_UUID}:cryptlvm root=/dev/${ENCRYPT_VG}/${ENCRYPT_LV_ROOT} cryptkey=rootfs:/root/secrets/cryptlvm.keyfile"
fi

SWAP_CMD_LINE_STR=""
if [ "${HAS_SWAP}" != "false" ] ; then
   SWAP_UUID=$(blkid | grep ${SWAP_LV} | cut -d'"' -f 2)
   SWAP_CMD_LINE_STR="resume=UUID=${SWAP_UUID}"
fi

GRUB_CMD_LINE_STR="net.ifnames=0 biosdevname=0 ${ENCRYPT_CMD_LINE_STR} ${SWAP_CMD_LINE_STR}"

echo ">>>>>>>>>>>>>>>> HOSTNAME: ${HOSTNAME}"
echo ">>>>>>>>>>>>>>>> DOMAINE_NAME: ${DOMAINE_NAME}"
echo ">>>>>>>>>>>>>>>> KEYMAP: ${KEYMAP}"
echo ">>>>>>>>>>>>>>>> LOCALE: ${LOCALE}"
echo ">>>>>>>>>>>>>>>> COUNTRIES: ${COUNTRIES}"
echo ">>>>>>>>>>>>>>>> ANSIBLE_LOGIN: $ANSIBLE_LOGIN"
echo ">>>>>>>>>>>>>>>> ANSIBLE_PASSWORD: $ANSIBLE_PASSWORD"
echo ">>>>>>>>>>>>>>>> WITH_WIFI: $WITH_WIFI"
echo ">>>>>>>>>>>>>>>> IS_UEFI: $IS_UEFI"
echo ">>>>>>>>>>>>>>>> IS_UEFI_REMOVABLE: $IS_UEFI_REMOVABLE"
echo ">>>>>>>>>>>>>>>> IS_ENCRYPTED: $IS_ENCRYPTED"
echo ">>>>>>>>>>>>>>>> ENCRYPT_CMD_LINE_STR: $ENCRYPT_CMD_LINE_STR"
echo ">>>>>>>>>>>>>>>> GRUB_PART: $GRUB_PART"
echo ">>>>>>>>>>>>>>>> GRUB_CMD_LINE_STR: $GRUB_CMD_LINE_STR"
echo ">>>>>>>>>>>>>>>> HAS_SWAP: $HAS_SWAP"
echo ">>>>>>>>>>>>>>>> SWAP_LV: $SWAP_LV"
echo ">>>>>>>>>>>>>>>> SWAP_CMD_LINE_STR: $SWAP_CMD_LINE_STR"
echo ">>>>>>>>>>>>>>>> BASE_PKGS: $BASE_PKGS"
echo ">>>>>>>>>>>>>>>> ADDITIONAL_PKGS: $ADDITIONAL_PKGS"
echo ">>>>>>>>>>>>>>>> GRUB_PKGS: $GRUB_PKGS"

TIMEZONE='UTC'
CONFIG_SCRIPT='/root/arch-config.sh'
TARGET_DIR='/mnt'

# #######################################
#
#
#
# #######################################

echo ">>>> install-base.sh: Setting pacman ${COUNTRIES} mirrors.."
/usr/bin/reflector --verbose  --country ${COUNTRIES} --latest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo ">>>> install-base.sh: Bootstrapping the base installation.."
/usr/bin/pacstrap -K ${TARGET_DIR} base base-devel linux-lts linux-lts-headers linux-firmware lvm2

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
/usr/bin/install --mode=0644 --group=root --owner=root /root/.ssh/authorized_keys "${TARGET_DIR}/ansible.pub"

if [ -d "/root/private/systemd/network/${HOSTNAME}" ]; then
  mkdir -p "${TARGET_DIR}/etc/systemd/network"
  /usr/bin/install --mode=0644 --group=root --owner=root /root/private/systemd/network/${HOSTNAME}/* ${TARGET_DIR}/etc/systemd/network
fi

if [ "${WITH_WIFI}" == "true" ] ; then
  echo ">>>> install-base.sh: copy wifi networks"
  mkdir -p ${TARGET_DIR}/var/lib/iwd
  /usr/bin/install --mode=0600 --group=root --owner=root /var/lib/iwd/* ${TARGET_DIR}/var/lib/iwd
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
  
  /usr/bin/sed -i '/^#\s*en_US.UTF-8 UTF-8/s/^#\s*//' /etc/locale.gen
  /usr/bin/sed -i "/^#${LOCALE}/s/^#\s*//" /etc/locale.gen
  /usr/bin/locale-gen

# #######################################
# mkinitcpio.conf
# #######################################
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: add lvm2 for initramfs.."
  /usr/bin/sed -i 's/block filesystems/block lvm2 filesystems/' /etc/mkinitcpio.conf
  if [ "${HAS_SWAP}" != "false" ] ; then
    /usr/bin/sed -i 's/lvm2 filesystems/lvm2 resume filesystems/' /etc/mkinitcpio.conf
  fi
  if [ "${IS_ENCRYPTED}" != "false" ] ; then
    echo ">>>> ${CONFIG_SCRIPT_SHORT}: add encrypt for initramfs.."
    mkdir /root/secrets
    dd bs=512 count=4 if=/dev/random of=/root/secrets/cryptlvm.keyfile iflag=fullblock
    chmod 600 /root/secrets/cryptlvm.keyfile
    cryptsetup -v luksAddKey ${ENCRYPT_PART} /root/secrets/cryptlvm.keyfile
    /usr/bin/sed -i 's/block lvm2/block encrypt lvm2/' /etc/mkinitcpio.conf
    /usr/bin/sed -i 's|FILES=(.*|FILES=(/root/secrets/cryptlvm.keyfile)|' /etc/mkinitcpio.conf
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
  rm  -f /etc/ssh/*.key
  rm  -f /etc/ssh/*_key
  ssh-keygen -A

# #######################################
# ufw
# #######################################

  systemctl enable ufw

  
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

# #######################################
# Ansible
# #######################################
  rm -rf /etc/ansible 
  git -C /etc clone  https://github.com/jubeaz/jubeaz_recovery.git ansible
  chmod 740 /etc/ansible
  chown --recursive ${ANSIBLE_LOGIN}:root /etc/ansible
  rm -rf /home/${ANSIBLE_LOGIN}/.bash*
  sudo -u ${ANSIBLE_LOGIN} /usr/bin/git clone --bare https://github.com/jubeaz/dotfiles.git /home/${ANSIBLE_LOGIN}/.dotfiles
  sudo -u ${ANSIBLE_LOGIN} /usr/bin/git --git-dir=/home/${ANSIBLE_LOGIN}/.dotfiles/ --work-tree=/home/${ANSIBLE_LOGIN} checkout
  
  chown --recursive ${ANSIBLE_LOGIN}:${ANSIBLE_LOGIN} /home/$ANSIBLE_LOGIN}/.[a-z]*

# #######################################
# grub
# #######################################

  # GRUB_CMDLINE_LINUX (params always add) 
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: setting grub kernel boot params"

  if [ "${IS_ENCRYPTED}" != "false" ] ; then
    /usr/bin/sed -i 's/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/'  /etc/default/grub
  fi
  /usr/bin/sed -i  '/GRUB_CMDLINE_LINUX=.*/d' /etc/default/grub
  echo 'GRUB_CMDLINE_LINUX="'${GRUB_CMD_LINE_STR}'"'  >> /etc/default/grub

  # GRUB_CMDLINE_LINUX_DEFAULT (params added in normal mode only)
  /usr/bin/sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 ipv6.disable=1 lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub

  if [ "${IS_UEFI}" != "false" ] ; then
    echo ">>>> ${CONFIG_SCRIPT_SHORT}: UEFI setup"
    mkdir -p /boot/efi
    mkfs.vfat -F32 ${GRUB_PART}
    echo ">>>> mount ${GRUB_PART} /boot/efi"
    mount ${GRUB_PART} /boot/efi
    mkdir -p /boot/efi/EFI
    if [ "${IS_UEFI_REMOVABLE}" != "true" ] ; then
      echo ">>>> grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub_uefi --recheck"
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub_uefi --recheck
    else
        echo ">>>> grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub_uefi --removable"
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub_uefi --removable
    fi
    mkdir -p /boot/grub/locale
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
    grub-mkconfig -o /boot/grub/grub.cfg
  else
    echo ">>>> ${CONFIG_SCRIPT_SHORT}: BIOS setup"
    echo ">>>> grub-install --target=i386-pc --recheck ${GRUB_PART}"
    grub-install --target=i386-pc --recheck ${GRUB_PART}
    # mkdir /boot/grub/locale
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
    grub-mkconfig -o /boot/grub/grub.cfg
  fi
  chmod 700 /boot
# #######################################
#
# #######################################
# Disable root login
  passwd -l root
EOF

echo ">>>> install-base.sh: Entering chroot and configuring system.."
/usr/bin/arch-chroot ${TARGET_DIR} ${CONFIG_SCRIPT}
#rm "${TARGET_DIR}${CONFIG_SCRIPT}"

echo ">>>> install-base.sh: Completing installation.."
/usr/bin/sleep 3
/usr/bin/umount -R ${TARGET_DIR}
/usr/bin/systemctl reboot
echo ">>>> install-base.sh: Installation complete!"
echo ">>>>>>>>>>>>>>>>>> DONE >>>>>>>>>>>>>>>>>>>>"

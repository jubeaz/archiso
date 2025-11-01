create my Archlinux iso

# `install-base.sh` script

## pre-setup

`install-base.sh` `/root/prepare.sh` is used to:
* set all the setup parameters y exporting variables
* prepare the file system and mount it in `TARGET_DIR=${TARGET_DIR:-'/mnt'}`
* generate the systemd-networkd config in `/root/private/systemd/network/${HOSTNAME}`
 
## filesystem

`lvm2`

support:
* swap
* luks encrypted

In case of encrypted filesystem the script generate a `cryptkey` in `/root/secrets/cryptlvm.keyfile`

## setup

* Packages installed:
    * grub packages depending of uefi or not
    * base packages
    * additional packages: `ADDITIONAL_PKGS=${ADDITIONAL_PKGS:-""}`

* Bootloader:
    * `grub` (nothing special)

* Basic setup:
    * `/etc/hosts` based on `${HOSTNAME}` and `${DOMAINE_NAME}`
    * keyboard based on `${KEYMAP}`
    * zoneinfo based on `${TIMEZONE}`
    * locale for  `en_US.UTF-8 UTF-8` plus `${LOCALE}`

* Network setup:
    * wifi if `"${WITH_WIFI}" == "true"`:
        * use `iwd`
        * copy all iwd file from iso image folder `/var/lib/iwd`
    * `systemd-networkd`: 
    * `systemd-resolved`:

* Pacman setup:
    * mirror list computed by `reflector` based on `${COUNTRIES:-France,Germany}` (https, best 5 based on rate)
    * enable `reflector.timer`

* Initial user setup:
    * `${ANSIBLE_LOGIN}`
    * `${ANSIBLE_PASSWORD}`
    * grant him sudo `ALL NOPASSWD: ALL`
    * ssh `authorized_keys` copied from root user `authorized_keys`
    * setup dotfiles according to (https://github.com/jubeaz/dotfiles.git)


* Hardening setup:
    * `ufw`: installed bu not enabled
    * `root` is disabled
    * no core dump
    * Disable uncommon protocols (`dccp`, `sctp`, `rds`, `tipc`)
    * password hardened:
    * password policy:
        * `PASS_MAX_DAYS 183`
        * `PASS_MAX_DAYS 1`
        * `PASS_WARN_AGE 15`

* Misc setup: 
    * Clone  [jubeaz_recovery](https://github.com/jubeaz/jubeaz_recovery.git) only if `"${INCLUDE_RECOVERY}" == "true"`

# build
```bash
make clean
make crypt
make build
sudo make burn ISO=archlinux-2025.03.18-x86_64.iso DEVICE=sda
```
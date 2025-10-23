create my Archlinux iso

# `install-base.sh` script

* `/root/prepare.sh` is used to set all the setup parameters and to prepare the file system up to mounting on `TARGET_DIR=${TARGET_DIR:-'/mnt'}`
 

* wifi if `"${WITH_WIFI}" == "true"`:
    * use `iwd`
    * copy all iwd file from iso image folder `/var/lib/iwd`
* Install:
    * grub packages depending of uefi or not
    * base packages
    * additional packages: `ADDITIONAL_PKGS=${ADDITIONAL_PKGS:-""}`
* setup reflector for:
    * `${COUNTRIES:-France,Germany}`
    * proto: https
    * latest: 5
    * sort: rate
* enable reflector timer

* Create initial user:
    * `${ANSIBLE_LOGIN}`
    * `${ANSIBLE_PASSWORD}`
    * grant him sudo `ALL NOPASSWD: ALL`
    * ssh `authorized_keys` copied from root user `authorized_keys`
    * setup dotfiles according to (https://github.com/jubeaz/dotfiles.git)

* Hardening:
    * 
* GRUB:

# on target
```bash
loadkeys fr
bash /root/unsecret.sh
```


# build
```bash
make clean
make crypt
make build
sudo make burn ISO=archlinux-2025.03.18-x86_64.iso DEVICE=sda
```
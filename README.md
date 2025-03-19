create my Archlinux iso

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
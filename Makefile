ISO_NAME := archlinux-$(shell date +%Y.%m.%d)-x86_64.iso
LOGIN := $(shell whoami)
OUT_DIR = test
crypt:
	tar czfh ./private.tgz ./private
	openssl enc -e -base64 -pbkdf2 -aes-256-cbc -salt  -in ./private.tgz -out ./private.tgz.enc
	rm private.tgz
clean:
	sudo rm -rf work
	sudo rm -rf test
	rm -rf releng
	rm -f ./scripts/airootfs/root/private.tgz.enc
	rm -f ./scripts/airootfs/var/lib/iwd/*.psk

build:
	cp -r /usr/share/archiso/configs/releng .
	cp ./private.tgz.enc  ./scripts/airootfs/root/private.tgz.enc
	cp ./private/*.psk  ./scripts/airootfs/var/lib/iwd/
	cp -r scripts/* releng
	sudo mkarchiso -v -o $(OUT_DIR) releng
	sudo chown $(LOGIN) $(OUT_DIR)
	sudo chown $(LOGIN) $(OUT_DIR)/$(ISO_NAME)
	sha256sum $(OUT_DIR)/$(ISO_NAME) > $(OUT_DIR)/$(ISO_NAME).sum
burn:
	dd bs=4M if=$(OUT_DIR)/$(ISO_NAME)  of=/dev/$(DEVICE) conv=fsync oflag=direct status=progress


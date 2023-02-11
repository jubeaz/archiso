crypt:
	tar czfh ./private.tgz ./private
	openssl enc -e -base64 -pbkdf2 -aes-256-cbc -salt  -in ./private.tgz -out ./private.tgz.enc
	rm private.tgz
clean:
	sudo rm -rf work
	sudo rm -rf test
	rm -rf releng
	rm -f ./scripts/airootfs/root/private.tgz.enc
	rm -f ./scripts/airootfs/var/lib/iwd/wifi.psk

build:
	cp -r /usr/share/archiso/configs/releng .
	cp ./private.tgz.enc  ./scripts/airootfs/root/private.tgz.enc
	cp ./private/wifi.psk  ./scripts/airootfs/var/lib/iwd/wifi.psk
	cp -r scripts/* releng
	sudo mkarchiso -v -o test releng
burn:
	dd bs=4M if=./test/archlinux-2023.02.11-x86_64.iso of=/dev/sdc conv=fsync oflag=direct status=progress


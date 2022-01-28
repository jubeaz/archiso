crypt:
	openssl enc -e -base64 -pbkdf2 -aes-256-cbc -salt  -in ./private/secrets.sh -out ./scripts/airootfs/root/secrets.sh
	openssl enc -e -base64 -pbkdf2 -aes-256-cbc -salt  -in ./private/wifi.psk   -out ./scripts/airootfs/var/lib/iwd/wifi.psk
clean:
	sudo rm -rf work
	sudo rm -rf test
	rm -r releng
	rm ./scripts/airootfs/root/secrets.sh
	rm ./scripts/airootfs/var/lib/iwd/wifi.psk
build:
	cp -r /usr/share/archiso/configs/releng .
	cp -r scripts/* releng
	openssl enc -d -base64 -pbkdf2 -aes-256-cbc -salt -in ./scripts/airootfs/var/lib/iwd/wifi.psk -out ./releng/airootfs/var/lib/iwd/wifi.psk
	sudo mkarchiso -v -o test releng
burn:
	dd bs=4M if=./test/archlinux-2021.12.26-x86_64.iso of=/dev/sdd conv=fsync oflag=direct status=progress

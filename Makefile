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
	sudo mkarchiso -v -o test releng
burn:
	dd bs=4M if=./test/$(ISO)  of=/dev/$(DEVICE) conv=fsync oflag=direct status=progress


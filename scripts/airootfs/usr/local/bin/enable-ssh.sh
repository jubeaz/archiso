#!/usr/bin/env bash

if [ $# -lt 2 ]
then
    echo "Error command line : $0 <login>  <password> "
    exit 1
fi



#PASSWORD=$(/usr/bin/openssl passwd -crypt $2)
# packer-specific configuration
/usr/bin/useradd  --create-home --user-group packer
echo "$1:$2" | /usr/bin/chpasswd 
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/packer
echo 'packer ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/packer
/usr/bin/chmod 0440 /etc/sudoers.d/packer
/usr/bin/systemctl start sshd.service

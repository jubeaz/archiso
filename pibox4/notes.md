https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4

# Setup SD Card
```bash
./sd_burner.sh
```

# find and connect on eth (dhcp)

```bash
sudo nmap -sn <network_ip>.<dhcp_start>-<dhcp_end>

sshpass -p root ssh root@<ip>
```

# init
```bash
bash /root/init.sh
```

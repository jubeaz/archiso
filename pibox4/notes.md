https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
https://archlinuxarm.org/wiki/Raspberry_Pi

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

# `config.txt`
https://elinux.org/RPiconfig


vcgencmd get_config int

## pimedia
```
```

## piblack
```
```


# ansible facts
```
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.2.249"
        ],
        "ansible_all_ipv6_addresses": [
            "fe80::2ecf:67ff:fe76:d43c"
        ],
        "ansible_apparmor": {
            "status": "disabled"
        },
        "ansible_architecture": "aarch64",
        "ansible_bios_date": "NA",
        "ansible_bios_vendor": "NA",
        "ansible_bios_version": "NA",
        "ansible_board_asset_tag": "NA",
        "ansible_board_name": "NA",
        "ansible_board_serial": "NA",
        "ansible_board_vendor": "NA",
        "ansible_board_version": "NA",
        "ansible_chassis_asset_tag": "NA",
        "ansible_chassis_serial": "NA",
        "ansible_chassis_vendor": "NA",
        "ansible_chassis_version": "NA",
        "ansible_cmdline": {
            "console": "tty0",
            "root": "PARTUUID=5840b43b-02",
            "rootwait": true,
            "rw": true,
            "smsc95xx.macaddr": "2c:cf:67:76:d4:3c"
        },
        "ansible_date_time": {
            "date": "2025-04-24",
            "day": "24",
            "epoch": "1745454595",
            "epoch_int": "1745454595",
            "hour": "02",
            "iso8601": "2025-04-24T00:29:55Z",
            "iso8601_basic": "20250424T022955197908",
            "iso8601_basic_short": "20250424T022955",
            "iso8601_micro": "2025-04-24T00:29:55.197908Z",
            "minute": "29",
            "month": "04",
            "second": "55",
            "time": "02:29:55",
            "tz": "CEST",
            "tz_dst": "CEST",
            "tz_offset": "+0200",
            "weekday": "Thursday",
            "weekday_number": "4",
            "weeknumber": "16",
            "year": "2025"
        },
        "ansible_default_ipv4": {
            "address": "192.168.2.249",
            "alias": "end0",
            "broadcast": "",
            "gateway": "192.168.2.1",
            "interface": "end0",
            "macaddress": "2c:cf:67:76:d4:3c",
            "mtu": 1500,
            "netmask": "255.255.255.0",
            "network": "192.168.2.0",
            "prefix": "24",
            "type": "ether"
        },
        "ansible_default_ipv6": {},
        "ansible_device_links": {
            "ids": {
                "mmcblk0": [
                    "mmc-ED4QT_0xdd2b53c2"
                ],
                "mmcblk0p1": [
                    "mmc-ED4QT_0xdd2b53c2-part1"
                ],
                "mmcblk0p2": [
                    "mmc-ED4QT_0xdd2b53c2-part2"
                ]
            },
            "labels": {},
            "masters": {},
            "uuids": {
                "mmcblk0p1": [
                    "7435-64ED"
                ],
                "mmcblk0p2": [
                    "57b2dba4-b352-4541-b98a-3b4c62f10da5"
                ]
            }
        },
        "ansible_devices": {
            "loop0": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 0,
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop1": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 0,
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop2": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 0,
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop3": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 0,
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop4": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 0,
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop5": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 0,
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop6": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 0,
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop7": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 0,
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "mmcblk0": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [
                        "mmc-ED4QT_0xdd2b53c2"
                    ],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {
                    "mmcblk0p1": {
                        "holders": [],
                        "links": {
                            "ids": [
                                "mmc-ED4QT_0xdd2b53c2-part1"
                            ],
                            "labels": [],
                            "masters": [],
                            "uuids": [
                                "7435-64ED"
                            ]
                        },
                        "sectors": 819200,
                        "sectorsize": 512,
                        "size": "400.00 MB",
                        "start": "2048",
                        "uuid": "7435-64ED"
                    },
                    "mmcblk0p2": {
                        "holders": [],
                        "links": {
                            "ids": [
                                "mmc-ED4QT_0xdd2b53c2-part2"
                            ],
                            "labels": [],
                            "masters": [],
                            "uuids": [
                                "57b2dba4-b352-4541-b98a-3b4c62f10da5"
                            ]
                        },
                        "sectors": 249264128,
                        "sectorsize": 512,
                        "size": "118.86 GB",
                        "start": "821248",
                        "uuid": "57b2dba4-b352-4541-b98a-3b4c62f10da5"
                    }
                },
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": 250085376,
                "sectorsize": "512",
                "serial": "0xdd2b53c2",
                "size": "119.25 GB",
                "support_discard": "16777216",
                "vendor": null,
                "virtual": 1
            }
        },
        "ansible_distribution": "Archlinux",
        "ansible_distribution_file_path": "/etc/arch-release",
        "ansible_distribution_file_variety": "Archlinux",
        "ansible_distribution_major_version": "NA",
        "ansible_distribution_release": "NA",
        "ansible_distribution_version": "NA",
        "ansible_dns": {
            "nameservers": [
                "8.8.8.8",
                "192.168.2.1"
            ],
            "search": [
                "."
            ]
        },
        "ansible_domain": "",
        "ansible_effective_group_id": 1000,
        "ansible_effective_user_id": 1000,
        "ansible_end0": {
            "active": true,
            "device": "end0",
            "ipv4": {
                "address": "192.168.2.249",
                "broadcast": "",
                "netmask": "255.255.255.0",
                "network": "192.168.2.0",
                "prefix": "24"
            },
            "ipv6": [
                {
                    "address": "fe80::2ecf:67ff:fe76:d43c",
                    "prefix": "64",
                    "scope": "link"
                }
            ],
            "macaddress": "2c:cf:67:76:d4:3c",
            "module": "genet",
            "mtu": 1500,
            "pciid": "fd580000.ethernet",
            "promisc": false,
            "speed": 1000,
            "type": "ether"
        },
        "ansible_env": {
            "DBUS_SESSION_BUS_ADDRESS": "unix:path=/run/user/1000/bus",
            "HOME": "/home/jubeaz",
            "LC_CTYPE": "C.UTF-8",
            "LOGNAME": "jubeaz",
            "MAIL": "/var/spool/mail/jubeaz",
            "MOTD_SHOWN": "pam",
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/bin",
            "PWD": "/home/jubeaz",
            "SHELL": "/bin/bash",
            "SHLVL": "1",
            "SSH_AUTH_SOCK": "/tmp/ssh-XXXXftS0Ee/agent.1004",
            "SSH_CLIENT": "192.168.2.3 44504 22",
            "SSH_CONNECTION": "192.168.2.3 44504 192.168.2.249 22",
            "USER": "jubeaz",
            "XDG_RUNTIME_DIR": "/run/user/1000",
            "XDG_SESSION_CLASS": "user",
            "XDG_SESSION_ID": "8",
            "XDG_SESSION_TYPE": "tty",
            "_": "/usr/bin/python3.13"
        },
        "ansible_fibre_channel_wwn": [],
        "ansible_fips": false,
        "ansible_form_factor": "NA",
        "ansible_fqdn": "alarm",
        "ansible_hostname": "alarm",
        "ansible_hostnqn": "",
        "ansible_interfaces": [
            "end0",
            "wlan0",
            "lo"
        ],
        "ansible_is_chroot": false,
        "ansible_iscsi_iqn": "",
        "ansible_kernel": "6.14.3-1-aarch64-ARCH",
        "ansible_kernel_version": "#1 SMP PREEMPT_DYNAMIC Sun Apr 20 10:13:45 MDT 2025",
        "ansible_lo": {
            "active": true,
            "device": "lo",
            "ipv4": {
                "address": "127.0.0.1",
                "broadcast": "",
                "netmask": "255.0.0.0",
                "network": "127.0.0.0",
                "prefix": "8"
            },
            "ipv6": [
                {
                    "address": "::1",
                    "prefix": "128",
                    "scope": "host"
                }
            ],
            "mtu": 65536,
            "promisc": false,
            "type": "loopback"
        },
        "ansible_loadavg": {
            "15m": 0.00537109375,
            "1m": 0.08642578125,
            "5m": 0.03125
        },
        "ansible_local": {},
        "ansible_locally_reachable_ips": {
            "ipv4": [
                "127.0.0.0/8",
                "127.0.0.1",
                "192.168.2.249"
            ],
            "ipv6": [
                "::1",
                "fe80::2ecf:67ff:fe76:d43c"
            ]
        },
        "ansible_lsb": {},
        "ansible_lvm": "N/A",
        "ansible_machine": "aarch64",
        "ansible_machine_id": "a69c28bb01544597a19b89611e3dcc34",
        "ansible_memfree_mb": 3435,
        "ansible_memory_mb": {
            "nocache": {
                "free": 3635,
                "used": 140
            },
            "real": {
                "free": 3435,
                "total": 3775,
                "used": 340
            },
            "swap": {
                "cached": 0,
                "free": 0,
                "total": 0,
                "used": 0
            }
        },
        "ansible_memtotal_mb": 3775,
        "ansible_mounts": [
            {
                "block_available": 27756282,
                "block_size": 4096,
                "block_total": 30522530,
                "block_used": 2766248,
                "device": "/dev/mmcblk0p2",
                "dump": 0,
                "fstype": "ext4",
                "inode_available": 7698409,
                "inode_total": 7790592,
                "inode_used": 92183,
                "mount": "/",
                "options": "rw,relatime",
                "passno": 0,
                "size_available": 113689731072,
                "size_total": 125020282880,
                "uuid": "57b2dba4-b352-4541-b98a-3b4c62f10da5"
            },
            {
                "block_available": 36851,
                "block_size": 4096,
                "block_total": 102196,
                "block_used": 65345,
                "device": "/dev/mmcblk0p1",
                "dump": 0,
                "fstype": "vfat",
                "inode_available": 0,
                "inode_total": 0,
                "inode_used": 0,
                "mount": "/boot",
                "options": "rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro",
                "passno": 0,
                "size_available": 150941696,
                "size_total": 418594816,
                "uuid": "7435-64ED"
            }
        ],
        "ansible_nodename": "alarm",
        "ansible_os_family": "Archlinux",
        "ansible_pkg_mgr": "pacman",
        "ansible_proc_cmdline": {
            "console": [
                "ttyS1,115200",
                "tty0"
            ],
            "root": "PARTUUID=5840b43b-02",
            "rootwait": true,
            "rw": true,
            "smsc95xx.macaddr": "2c:cf:67:76:d4:3c"
        },
        "ansible_processor": [
            "0",
            "1",
            "2",
            "3"
        ],
        "ansible_processor_cores": 1,
        "ansible_processor_count": 4,
        "ansible_processor_nproc": 4,
        "ansible_processor_threads_per_core": 1,
        "ansible_processor_vcpus": 4,
        "ansible_product_name": "NA",
        "ansible_product_serial": "NA",
        "ansible_product_uuid": "NA",
        "ansible_product_version": "NA",
        "ansible_python": {
            "executable": "/usr/bin/python3.13",
            "has_sslcontext": true,
            "type": "cpython",
            "version": {
                "major": 3,
                "micro": 3,
                "minor": 13,
                "releaselevel": "final",
                "serial": 0
            },
            "version_info": [
                3,
                13,
                3,
                "final",
                0
            ]
        },
        "ansible_python_version": "3.13.3",
        "ansible_real_group_id": 1000,
        "ansible_real_user_id": 1000,
        "ansible_selinux": {
            "status": "Missing selinux Python library"
        },
        "ansible_selinux_python_present": false,
        "ansible_service_mgr": "systemd",
        "ansible_ssh_host_key_ecdsa_public": "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKcVgAAwhanZOHERG4FE2kwy2IjNyIAt4hpc7aF0e81To3l0P6qESlxv3s3aeLAc9z4VbK59CSEcq/ZchCQE3Q0=",
        "ansible_ssh_host_key_ecdsa_public_keytype": "ecdsa-sha2-nistp256",
        "ansible_ssh_host_key_ed25519_public": "AAAAC3NzaC1lZDI1NTE5AAAAIPcGeHpjjDB5BZa4U9VUwm5xs9IyNrjTg7UMera+QR+R",
        "ansible_ssh_host_key_ed25519_public_keytype": "ssh-ed25519",
        "ansible_ssh_host_key_rsa_public": "AAAAB3NzaC1yc2EAAAADAQABAAABgQDYiVTdrU3jxC240FWrWDRY19EwZM5r7kMBd2aEOXg5zOxkfQfOb3z/MRn4gKi05147JjLMq/zSbVzz/romH6IXnrObhdK9ex6ReUeCsHdj+fdhyHNssbkCBOBVvVVA+M0ICD0I5MG6jXrGBDlC4tLCqOEAUhcFe9wD0XlGMUsmRBMNO4Yw/ES6lCyw5sMTtJGVe5Meoc8Nf4bJxsT7cQKdNO28I2WbfZ35mHyKPIYxsP8v7T3X1dRoYNO6JFlqLVzpivTEQONPRauU6Saqbb++7+wLjiGIkfIv07kUex0lfPmEpuHXSwXvQ8x4HoArMIkCYqfpEImScT2VwtrNI2RSeb643cQbNVtclFO9fmatI7uwkJZ/o480qjVy7nGrhBJHKxojK+i58r9XnWsssZTPioEDujdWt8FYnhIXT5gUZ9+58XD7VUM3/BmFdM3AdkHaiUT5To2tvwpNjukcekCuf94zEw8/o1aCy3PLPqazuaRkNo/2vFsCkzR5vfPobI8=",
        "ansible_ssh_host_key_rsa_public_keytype": "ssh-rsa",
        "ansible_swapfree_mb": 0,
        "ansible_swaptotal_mb": 0,
        "ansible_system": "Linux",
        "ansible_system_capabilities": [
            ""
        ],
        "ansible_system_capabilities_enforced": "True",
        "ansible_system_vendor": "NA",
        "ansible_systemd": {
            "features": "+PAM +AUDIT -SELINUX -APPARMOR -IMA +IPE +SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBCRYPTSETUP_PLUGINS +LIBFDISK +PCRE2 +PWQUALITY +P11KIT +QRENCODE +TPM2 +BZIP2 +LZ4 +XZ +ZLIB +ZSTD +BPF_FRAMEWORK -BTF +XKBCOMMON +UTMP -SYSVINIT +LIBARCHIVE",
            "version": 257
        },
        "ansible_uptime_seconds": 4637,
        "ansible_user_dir": "/home/jubeaz",
        "ansible_user_gecos": "",
        "ansible_user_gid": 1000,
        "ansible_user_id": "jubeaz",
        "ansible_user_shell": "/bin/bash",
        "ansible_user_uid": 1000,
        "ansible_userspace_bits": "64",
        "ansible_virtualization_role": "host",
        "ansible_virtualization_tech_guest": [],
        "ansible_virtualization_tech_host": [
            "kvm"
        ],
        "ansible_virtualization_type": "kvm",
        "ansible_wlan0": {
            "active": false,
            "device": "wlan0",
            "macaddress": "2c:cf:67:76:d4:3d",
            "module": "brcmfmac",
            "mtu": 1500,
            "pciid": "mmc1:0001:1",
            "promisc": false,
            "type": "ether"
        },
        "discovered_interpreter_python": "/usr/bin/python3.13",
        "gather_subset": [
            "all"
        ],
        "module_setup": true
    },
    "changed": false
}
```



$ sudo hostapd /etc/hostapd/hostapd.conf
wlan0: interface state UNINITIALIZED->COUNTRY_UPDATE
wlan0: interface state COUNTRY_UPDATE->ENABLED
wlan0: AP-ENABLED
^Cwlan0: interface state ENABLED->DISABLED
wlan0: AP-DISABLED
wlan0: CTRL-EVENT-TERMINATING
nl80211: deinit ifname=wlan0 disabled_11b_rates=0


$ sudo hostapd /etc/hostapd/hostapd.conf
wlan0_ap: interface state UNINITIALIZED->COUNTRY_UPDATE
Could not set RTS threshold for kernel driver
Interface initialization failed
wlan0_ap: interface state COUNTRY_UPDATE->DISABLED
wlan0_ap: AP-DISABLED
wlan0_ap: Unable to setup interface.
wlan0_ap: interface state DISABLED->DISABLED
wlan0_ap: AP-DISABLED
wlan0_ap: CTRL-EVENT-TERMINATING
hostapd_free_hapd_data: Interface wlan0_ap wasn't started
nl80211: deinit ifname=wlan0_ap disabled_11b_rates=0

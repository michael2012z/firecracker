#!/bin/bash


# set guest kernel
arch=`uname -m`
# kernel_path=$(pwd)"/hello-vmlinux.bin"
kernel_path=$(pwd)"/custom-vmlinux.bin"



# set logfile

touch log.log

curl --unix-socket /tmp/firecracker.socket -i \
    -X PUT "http://localhost/logger" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{
             "log_path": "log.log",
             "level": "Debug",
             "show_level": true,
             "show_log_origin": true
    }"

# set kernel

if [ ${arch} = "x86_64" ]; then
    curl --unix-socket /tmp/firecracker.socket -i \
         -X PUT 'http://localhost/boot-source'   \
         -H 'Accept: application/json'           \
         -H 'Content-Type: application/json'     \
         -d "{
				\"kernel_image_path\": \"${kernel_path}\",
              	\"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
         	 }"
elif [ ${arch} = "aarch64" ]; then
    curl --unix-socket /tmp/firecracker.socket -i \
         -X PUT 'http://localhost/boot-source'   \
         -H 'Accept: application/json'           \
         -H 'Content-Type: application/json'     \
         -d "{
				\"kernel_image_path\": \"${kernel_path}\",
              	\"boot_args\": \"keep_bootcon console=ttyS0 reboot=k panic=1 pci=off\"
         	 }"
else
    echo "Cannot run firecracker on $arch architecture!"
    exit 1
fi

# set guest FS
rootfs_path=$(pwd)"/hello-rootfs.ext4"
curl --unix-socket /tmp/firecracker.socket -i \
     -X PUT 'http://localhost/drives/rootfs' \
     -H 'Accept: application/json'           \
     -H 'Content-Type: application/json'     \
     -d "{
			\"drive_id\": \"rootfs\",
          	\"path_on_host\": \"${rootfs_path}\",
          	\"is_root_device\": true,
          	\"is_read_only\": false
     	 }"

# start the VM
curl --unix-socket /tmp/firecracker.socket -i \
     -X PUT 'http://localhost/actions'       \
     -H  'Accept: application/json'          \
     -H  'Content-Type: application/json'    \
     -d '{
			"action_type": "InstanceStart"
     	 }'


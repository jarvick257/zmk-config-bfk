#!/bin/bash

set -e

mount_dir="/home/jarvick/usb"
device_name="NICENANO"

function firmware() {
  echo "/tmp/bfk_$1-nice_nano_v2-zmk.uf2"
}


function waitForDrive {
    while [ $(lsblk -fP | grep $device_name | wc -l) -eq 0 ]; do
        sleep 0.5
    done
    part=$(lsblk -fP | grep $device_name | sed -nE 's/.*NAME="(\S*)".*/\1/p')
    echo "/dev/$part"
}

function waitForFlash {
    while [[ -n $(lsblk -fP | grep $device_name | sed -nE 's/.*MOUNTPOINTS="(\S*)".*/\1/p') ]]; do
        sleep 1.0
    done
    sleep 3
}

for side in $(echo -e "left\nright"); do
    fw=$(firmware $side)

    echo "$side side: Waiting for $device_name"
    drive_name=$(waitForDrive)

    echo "$side side: Mounting $drive_name to $mount_dir"
    mount $drive_name $mount_dir

    echo "$side side: Copying $fw to device"
    cp $fw $mount_dir

    echo "$side side: Unmounting"
    umount $mount_dir

    echo "$side side: Waiting for flash"
    waitForFlash

    echo "Done"
done

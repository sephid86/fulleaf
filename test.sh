#!/bin/bash

sgdisk -o -n 1:0:+500M -t 1:EF00 -n 2:0:0 -t 2:8300 /dev/vda
mkfs.vfat -F32 /dev/vda1
mkfs.ext4 /dev/vda2
mount /dev/vda2 /mnt
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot
pacstrap -K /mnt base linux linux-firmware git

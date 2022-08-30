#!/bin/sh

#change this path to the path on your machine
PATH_TO_MOST_CURRENT_PELICAN_ISO="/home/user/stubborn_barnacle/current_make_pelican-v4.2/pelicanhpc-v4.2-xfce.iso"

sudo mount -o loop  $PATH_TO_MOST_CURRENT_PELICAN_ISO /usr/lib/live/mount/medium                      
#need to make a directory first
install -d /home/user/temp_mount_for_squash
sudo mount /usr/lib/live/mount/medium/live/filesystem.squashfs  /home/user/temp_mount_for_squash -t squashfs -o loop               
#cd /home/user/temp_mount_for_squash/usr/bin
#sudo cp *pelican* /usr/bin/

sudo cp /home/user/temp_mount_for_squash/usr/bin/*pelican* /usr/bin/
sudo cp /home/user/temp_mount_for_squash/initrd.img /srv/tftp/      
sudo cp /home/user/temp_mount_for_squash/vmlinuz /srv/tftp/

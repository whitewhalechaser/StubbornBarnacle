#!/bin/sh

# Run this after building an image for the first time, this will copy over the correct files to ther server.  Then reboot.  Probably should make this a separate  project
#run as "user", with sudo privlidges.  Like this: "sudo sh pre_pelican_setup_script"

#change this path to the path on your machine
PATH_TO_MOST_CURRENT_PELICAN_ISO="/home/user/stubborn_barnacle/current_make_pelican-v4.2/pelicanhpc-v4.2-min_no_gui.iso"

#make sure the appropriate directory exists, then mount the iso on it
sudo install -d /usr/lib/live/mount/medium
sudo mount -o loop  $PATH_TO_MOST_CURRENT_PELICAN_ISO /usr/lib/live/mount/medium                      



#now, need to extract some files from the squashfs on the iso. 
#need to make a directory first, then mount the squashfs
sudo install -d /tmp/temp_mount_for_squashfs
sudo mount /usr/lib/live/mount/medium/live/filesystem.squashfs  /tmp/temp_mount_for_squashfs -t squashfs -o loop

#update the scripts from new build, good for dogfooding this thing
sudo cp  /tmp/temp_mount_for_squashfs/usr/bin/*pelican* /usr/bin/

# this will overwrite the (possibly) previously generated initrd.img (created in the pelican_boot_setup, when server started) 
sudo install -d /srv/tftp/pxelinux.cfg
sudo cp  /tmp/temp_mount_for_squashfs/initrd.img /srv/tftp/
sudo cp  /tmp/temp_mount_for_squashfs/usr/lib/PXELINUX/pxelinux.0 /srv/tftp/
sudo cp  /tmp/temp_mount_for_squashfs/usr/lib/syslinux/modules/bios/ldlinux.c32 /srv/tftp/
sudo cp  /tmp/temp_mount_for_squashfs/boot/vmlinuz-* /srv/tftp/

# now, trying to get the correct file for the below script.  Cannot use 'uname -r', as the server's version of linux may be diff than
# the version on the iso.  Hoping there is just one "vmlinz..." file.
        VMLINZ_ON_ISO=$(find /tmp/temp_mount_for_squashfs/boot -type f -name "*vmlinuz-*" -printf "%f")

cat << PXECONFIG > /srv/tftp/pxelinux.cfg/default
DEFAULT linux
LABEL linux
KERNEL $VMLINZ_ON_ISO
APPEND initrd=initrd.img  nfsroot=10.11.12.1:/lib/live/mount/medium ip=dhcp rw noautologin noxautologin union=overlay netboot=nfs hostname=pelican mitigations=off boot=live noeject config quiet 3
PXECONFIG


#copy a few more files....
sudo cp  /tmp/temp_mount_for_squashfs/etc/rc.local /etc/
#sudo install -d /etc/skel
#sudo cp -r  /tmp/temp_mount_for_squashfs/etc/skel/* /etc/skel/

echo -n "PelicanHPC" > /home/user/pw

cat << SYSTEMDBS > /etc/systemd/system/rc-local.service
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
 
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
 
[Install]
WantedBy=multi-user.target
SYSTEMDBS


#enable the rc-local service
systemctl enable rc-local


#need to write the following line to /home/user/.ssh/config
#IdentityFile ~/.ssh/pelicanhpc_rsa
#not sure how to do that...


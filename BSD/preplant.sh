#!/bin/sh

BOLD="\033[1m"
RED="\033[31;1m"
CLEAR="\033[0m"

if [ $# -eq 1 ]; then
  :
else
  printf "${RED}Error:${CLEAR} You are supposeed to run this command with exactly 1 argument\n${BOLD}Usage:${CLEAR} $0 vulnName\n" >&2
  exit
fi

if [ -f currentSet.txt ]; then
  :
else
  printf "${RED}Error:${CLEAR} You must first run ./pick.sh to select which vulnerabilities you want. They will be stored as the file currentSet.txt\n" >&2
  exit
fi

if id | grep -q "uid=0"; then
  :
else 
  printf "${RED}Error:${CLEAR} $0 must be run as root\n" >&2
  exit
fi

RANDOM=$$$(date +%s)

#############
#   USERS   #
#############

noPasswd() {
  sed -i '' "s/jotaro:\*/jotaro:/" /etc/passwd
}
sudoGroup() {
  if grep -q wheel /etc/group; then
    pw usermod jolyne -G wheel
  else
    pw usermod jolyne -G sudo
  fi
}
sshKey() {
  mkdir -p /home/jolyne
  mkdir -p /home/jolyne/.ssh
  cp -f assets/authorized_keys /home/jolyne/.ssh/authorized_keys
}
uidRoot() {
  sed -i '' "s/joseph:\*:[^:]*:/joseph:x\*:0:/" /etc/passwd
}

admUser() {
  if grep -q jonathan /etc/passwd; then
    pw useradd jonathan
  fi
  pw usermod jonathan -g joestar
  if grep -q adm /etc/group; then
    pw usermod jonathan -G adm
  fi
}
dialUser() {
  if grep -q josuke /etc/passwd; then
    pw useradd josuke
  fi
  pw usermod josuke -g joestar
  if grep -q dialout /etc/group; then
    pw usermod josuke -G dialout
  fi
}
typoUser() {
  cp -f /bin/sh /usr/bin/nologin
  if grep -q kernpoops /etc/passwd; then
    pw useradd kernpoops
  fi
  pw usermod kernpoops -s "/usr/bin/nologin"
}
noShadow() {
  cp -f "/bin/sh" "/bin/false"
  sed -i '' "s/sys:\*:/sys::/" /etc/shadow
  pw usermod sys -s "/bin/false"
}

###################
#   PERMISSIONS   #
###################

aclPasswd() {
  for u in $(cat /etc/passwd | cut -d ":" -f1); do
    if mount | grep -q nfsv4acls; then
      setfacl -m user:$u:rwxpDdaARWcCos:allow /etc/passwd
    else
      setfacl -m u:$u:rwx /etc/passwd
    fi
  done
}
aclShadow() {
  for u in $(cat /etc/passwd | cut -d ":" -f1); do
    if mount | grep -q nfsv4acls; then
      setfacl -m user:$u:rwxpDdaARWcCos:allow /etc/master.passwd
    else
      setfacl -m u:$u:rwx /etc/master.passwd
    fi
  done
}
bashCopy() {
  randVar=$(cat /dev/urandom | head -c 6 | base64 -w0 | tr -d "+" | tr -d "/")
  randVar="xkcd$randVar"
  f="/bin/bash"
  if [ -f $f ]; then
    cp -f $f /bin/$randVar
    chmod u+s $f /bin/$randVar
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
zshSUID() {
  f="/bin/zsh"
  if [ -f $f ]; then
    chmod u+s $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
fishSUID() {
  f="/bin/fish"
  if [ -f $f ]; then
    chmod u+s $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
falseSUID() {
  f="/bin/false"
  if [ -f $f ]; then
    chmod u+s $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
vimSUID() {
  f="/usr/bin/vim"
  if [ -f $f ]; then
    chmod u+s $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
catSUID() {
  f="/bin/cat"
  if [ -f $f ]; then
    chmod u+s $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}

##############
#   SYSTEM   #
##############

sudoAll() {
  for u in $(cat /etc/passwd | awk -F: '{print $1}'); do
    if grep -q sudo /etc/group; then
      pw usermod $u -G sudo
    elif grep -q wheel /etc/group; then
      pw usermod $u -G wheel
    fi
  done
}
fakeSudod() {
  dir="/etc/sudoers.d"
  if [ -d $dir ]; then
    randomVal=$((RANDOM % 3))
    case $randomVal in
      0)  echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> "$dir/ ";;
      1)  echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> "$dir/  ";;
      2)  echo "ALL   ALL=(ALL:ALL) NOPASSWD:ALL" >> "$dir/README"
    esac
  else
    printf "${RED}Warning:${CLEAR} $dir does not exist on the system. Skipping this vuln...\n"
  fi
}
vimSudo() {
  f="/usr/bin/vim"
  if [ -f $f ] && [ -f /etc/sudoers ]; then
    echo "%sudo ALL=(ALL:ALL) NOPASSWD:/usr/bin/vim" >> /etc/sudoers
  else
    printf "${RED}Warning:${CLEAR} $f or /etc/sudoers does not exist on the system. Skipping this vuln...\n"
  fi
}
sudoUser() {
  f="/etc/sudoers"
  if [ -f $f ]; then
    echo "joestar ALL=(ALL:ALL) NOPASSWD:ALL" >> $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
pamCommonAuth() {
  f="/etc/pam.d/common-auth"
  if [ -f $f ]; then
    sed -ie "s/nullok_secure/nullok/g" $f
    sed -ie "s/pam_rootok.so/pam_permit.so/g" $f
    sed -ie "s/pam_deny.so/pam_permit.so/g" $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
pamSu() {
  f="/etc/pam.d/su"
  if [ -f $f ]; then
    sed -ie "s/pam_rootok.so/pam_permit.so/g" $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
pamPermit() {
  if [ -f "/lib/x86_64-linux-gnu/security/pam_permit.so" ]; then
    pam_path="/lib/x86_64-linux-gnu/security"
  else
    pam_path="/usr/lib"
  fi
  cp -f $pam_path/pam_permit.so $pam_path/pam_deny.so
}

$1

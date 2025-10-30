#!/bin/sh

# Initialize variables
WHITE="\033[1m"
GREEN="\033[32;1m"
RED="\033[31;1m"
CLEAR="\033[0m"
PASS="${GREEN} PASS:${CLEAR}"
FAIL="${RED} FAIL:${CLEAR}"
cheat=false

# Parse flags
while [ $# -gt 0 ]; do
  case $1 in
    -c | --cheat) cheat=true;;
    -h | --help) printf "This program iterates through all vulnerabilities picked in ${WHITE}currentSet.txt${CLEAR} and check to see if they have been patched. If you successfully patched a vuln, you will see a message like:\n  ${PASS} Description of the vuln\n\nIf you're stuck, you can use the ${WHITE}-c or --cheat${CLEAR} flag to show which vulns have not been patched:\n  ${FAIL} Description of the vuln\n" >&2
       exit;;
    *) echo "Invalid flag $1. Use -h to figure out how $0 works" >&2
       exit;;
  esac
  shift
done

# Checks
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


check() {
  if [ "$2" = true ]; then
    if eval "$1"; then
      printf "$PASS $3\n"
      return 0
    else
      if [ "$cheat" = true ]; then
        printf "$FAIL $3\n"
      fi
      return 1
    fi
  else
    if eval "$1"; then
      if [ "$cheat" = true ]; then
        printf "$FAIL $3\n"
      fi
      return 1
    else
      printf "$PASS $3\n"
      return 0
    fi
  fi
}

#############
#   USERS   #
#############

noPasswd() {
  if check "grep -q jotaro:x: /etc/passwd" true "jotaro has empty password in /etc/passwd"; then
    correct=$(($correct+1))
  fi
}
sudoGroup() {
  if check "grep jolyne /etc/passwd | grep -q -e sudo -e wheel" true "jolyne is part of sudo/wheel group"; then
    correct=$(($correct+1))
  fi
}
sshKey() {
  if check "[ -f /home/jolyne/.ssh/authorized_keys ] && grep -q pyukey@pop-os /home/jolyne/.ssh/authorized_keys" false "jolyne has authorized SSH key"; then
    correct=$(($correct+1))
  fi
}
uidRoot() {
  if check "awk -F: '{print \$1\" \"\$3}' /etc/passwd | grep joseph | grep -q 0" false "joseph has UID 0"; then
    correct=$(($correct+1))
  fi
}
admUser() {
  if check "grep jonathan /etc/group | grep -q adm" false "jonathan is part of adm group"; then
    correct=$(($correct+1))
  fi
}
dialUser() {
  if check "grep josuke /etc/group | grep -q dialout" false "josuke is part of dialout group"; then
    correct=$(($correct+1))
  fi
}
typoUser() {
  if check "grep -q -e kernpoops -e /usr/bin/nologin /etc/passwd" false "Typosquat user kernpoops impersonating kernoops & Typosquat login shell /usr/bin/nologin impersonating /usr/sbin/nologin"; then
    correct=$(($correct+1))
  fi
}
noShadow() {
  if check "grep -q sys:*: /etc/shadow && diff /bin/sh /bin/false | grep -q differ" true "sys has empty password in /etc/shadow & /bin/false replacced with /bin/sh"; then
    correct=$(($correct+1))
  fi
}


###################
#   PERMISSIONS   #
###################

aclPasswd() {
  if check "ls -l /etc/passwd | awk '{print \$1}' | grep -q +" false "acls set for /etc/passwd"; then
    correct=$(($correct+1))
  fi
}
aclShadow() {
  if check "ls -l /etc/shadow | awk '{print \$1}' | grep -q +" false "acls set for /etc/shadow"; then
    correct=$(($correct+1))
  fi
}
capCat() {
  if check "getcap /bin/cat | grep -q cap_dac_override" false "Capabilities allows cat to read any file"; then
    correct=$(($correct+1))
  fi
}
capVim() {
  if check "getcap /usr/bin/vim.basic | grep -q cap_dac_override" false "Capabilities allows vim to read any file"; then
    correct=$(($correct+1))
  fi
}
capLess() {
  lessPath="$(which less)"
  if check "getcap $lessPath | grep -q cap_dac_override" false "Capabilities allows less to read any file"; then
    correct=$(($correct+1))
  fi
}
bashCopy() {
  if check "ls /bin | grep -q xkcd" false "Random copy of bash"; then
    correct=$(($correct+1))
  fi
}
zshSUID() {
  if check "[ -f /bin/zsh ] && ls -l /bin/zsh | awk '{print \$1}' | grep -q s" false "/bin/zsh has SUID bit set"; then
    correct=$(($correct+1))
  fi
}
fishSUID() {
  if check "[ -f /bin/fish ] && ls -l /bin/fish | awk '{print \$1}' | grep -q s" false "/bin/fish has SUID bit set"; then
    correct=$(($correct+1))
  fi
}
falseSUID() {
  if check "ls -l /bin/false | awk '{print \$1}' | grep -q s" false "/bin/false has SUID bit set - even if it can't be exploited, it's still bad practice"; then
    correct=$(($correct+1))
  fi
}
vimSUID() {
  if check "ls -l /usr/bin/vim | awk '{print \$1}' | grep -q s" false "/usr/bin/vim has SUID bit set"; then
    correct=$(($correct+1))
  fi
}
catSUID() {
  if check "ls -l /bin/cat | awk '{print \$1}' | grep -q s" false "/bin/cat has SUID bit set"; then
    correct=$(($correct+1))
  fi
}


##############
#   SYSTEM   #
##############

sudoAll() {
  if check false false "TODO: This check has not been implemented yet"; then
    correct=$(($correct+1))
  fi
}
fakeSudod() {
  if check "grep -q -r NOPASSWD:ALL /etc/sudoers.d/" false "/etc/sudoers.d/ has backdoored file with NOPASSWD:ALL"; then
    correct=$(($correct+1))
  fi
}
vimSudo() {
  if check "grep -q NOPASSWD:/usr/bin/vim /etc/sudoers" false "/etc/sudoers sudo group can run vim with NOPASSWD"; then
    correct=$(($correct+1))
  fi
}
sudoUser() {
  if check "grep -q NOPASSWD:ALL /etc/sudoers" false "/etc/sudoers joestar group can run ALL with NOPASSWD"; then
    correct=$(($correct+1))
  fi
}
pamCommonAuth() {
  if check "grep -q pam_deny.so /etc/pam.d/common-auth" true "PAM common-auth has been backdoored to always pam_permit.so (Check is not thorough and should be manually validated)"; then
    correct=$(($correct+1))
  fi
}
pamSu() {
  if check "grep -q pam_rootok.so /etc/pam.d/su" true "PAM su has been backdoored to always pam_permit.so (Check is not thorough and should be manually validated)"; then
    correct=$(($correct+1))
  fi
}
pamPermit() {
  pam_path=""
  if [ -f "/lib/x86_64-linux-gnu/security/pam_permit.so" ]; then
    pam_path="/lib/x86_64-linux-gnu/security"
  else
    pam_path="/lib/i386-linux-gnu/security"
  fi

  if check "diff $pam_path/pam_permit.so $pam_path/pam_deny.so | grep -q differ" true "pam_deny.so replaced with pam_permit.so --> NOTE: this test is not enabled since replacing pam_deny while root will segfault when returning to the normal user."; then
    correct=$(($correct+1))
  fi
}

####################
#   FINAL CHECKS   #
####################

checkUser() {
  numTests=$(grep -c -e "^user " config.txt)
  printf "${BOLD}USERS\n===================${CLEAR}\n"
  correct=0

  while read -r module difficulty func; do
    $func
  done < currentSet.user.txt

  if [ "$correct" -eq "$numTests" ]; then
    printf "\n${GREEN} Total score:${CLEAR} $correct / $numTests\n\n"
  else
    printf "\n${RED} Total score:${CLEAR} $correct / $numTests\n\n"
  fi
}

checkPermissions() {
  numTests=$(grep -c -e "^permissions " config.txt)
  printf "${BOLD}PERMISSIONS\n===================${CLEAR}\n"
  correct=0

  while read -r module difficulty func; do
    $func
  done < currentSet.permissions.txt

  if [ "$correct" -eq "$numTests" ]; then
    printf "\n${GREEN} Total score:${CLEAR} $correct / $numTests\n\n"
  else
    printf "\n${RED} Total score:${CLEAR} $correct / $numTests\n\n"
  fi
}

checkSystem() {
  numTests=$(grep -c -e "^system " config.txt)
  printf "${BOLD}SYSTEM\n===================${CLEAR}\n"
  correct=0
  
  while read -r module difficulty func; do
    $func
  done < currentSet.system.txt
  
  if [ "$correct" -eq "$numTests" ]; then
    printf "\n${GREEN} Total score:${CLEAR} $correct / $numTests\n\n"
  else
    printf "\n${RED} Total score:${CLEAR} $correct / $numTests\n\n"
  fi
}  

if grep -q -e "^user " currentSet.txt; then
  grep -e "^user " currentSet.txt > currentSet.user.txt
  checkUser
  rm currentSet.user.txt
fi
if grep -q -e "^permissions " currentSet.txt; then
  grep -e "^permissions " currentSet.txt > currentSet.permissions.txt
  checkPermissions
  rm currentSet.permissions.txt
fi
if grep -q -e "^system " currentSet.txt; then
  grep -e "^system " currentSet.txt > currentSet.system.txt
  checkSystem
  rm currentSet.system.txt
fi

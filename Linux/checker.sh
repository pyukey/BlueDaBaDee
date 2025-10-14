#!/bin/sh

# Initialize variables
PASS="\033[32;1m"
FAIL="\033[31;1m"
RESET="\033[0m"

PASSmsg="$PASS PASS:$RESET"
FAILmsg="$FAIL FAIL:$RESET"

cheat=false

# Parse flags
while [ $# -gt 0 ]; do
  case $1 in
    -c | --cheat) cheat=true;;
    *) echo "Invalid flag $1" >&2
       exit;;
  esac
  shift
done

check() {
  if [ "$2" = true ]; then
    if eval "$1"; then
      printf "$PASSmsg $3\n"
      return 0
    else
      if [ "$cheat" = true ]; then
        printf "$FAILmsg $3\n"
      fi
      return 1
    fi
  else
    if eval "$1"; then
      if [ "$cheat" = true ]; then
        printf "$FAILmsg $3\n"
      fi
      return 1
    else
      printf "$PASSmsg $3\n"
      return 0
    fi
  fi
}

checkUsers() {
  numTests=9
  printf "\033[1mUSERS\n===================\033[0m\n"
  correct=0

  if check "grep -q jotaro:x: /etc/passwd" true "jotaro has empty password in /etc/passwd"; then
    correct=$(($correct+1))
  fi

  if check "grep -q sys:*: /etc/shadow" true "sys has empty password in /etc/shadow"; then
    correct=$(($correct+1))
  fi

  if check "grep -q kernpoops /etc/passwd" false "Typosquat user kernpoops impersonating kernoops"; then
    correct=$(($correct+1))
  fi

  if check "[ -f /home/jolyne/.ssh/authorized_keys ] && grep -q pyukey@pop-os /home/jolyne/.ssh/authorized_keys" false "jolyne has authorized SSH key"; then
    correct=$(($correct+1))
  fi

  if check "awk -F: '{print \$1\" \"\$3}' /etc/passwd | grep joseph | grep -q 0" false "joseph has UID 0"; then
    correct=$(($correct+1))
  fi

  if check "grep jonathan /etc/group | grep -q adm" false "jonathan is part of adm group"; then
    correct=$(($correct+1))
  fi

  if check "grep josuke /etc/group | grep -q dialout" false "josuke is part of dialout group"; then
    correct=$(($correct+1))
  fi
  
  if check "grep /usr/bin/nologin /etc/passwd" false "Typosquat login shell /usr/bin/nologin impersonating /usr/sbin/nologin"; then
    correct=$(($correct+1))
  fi
  
  if check "diff /bin/sh /bin/false | grep -q differ" true "/bin/false replaced with /bin/sh"; then
    correct=$(($correct+1))
  fi
  
  if [ "$correct" -eq "$numTests" ]; then
    printf "\n$PASS Total score:$RESET $correct / $numTests\n\n"
  else
    printf "\n$FAIL Total score:$RESET $correct / $numTests\n\n"
  fi
}

checkPermissions() {
  numTests=12
  printf "\033[1mPERMISSIONS\n===================\033[0m\n"
  correct=0

  if check "ls -l /bin/cat | awk '{print \$1}' | grep -q s" false "/bin/cat has SUID bit set"; then
    correct=$(($correct+1))
  fi
  
  if check "ls -l /usr/bin/vim | awk '{print \$1}' | grep -q s" false "/usr/bin/vim has SUID bit set"; then
    correct=$(($correct+1))
  fi
  
  if check "ls -l /bin/bash | awk '{print \$1}' | grep -q s" false "/bin/bash has SUID bit set"; then
    correct=$(($correct+1))
  fi
  
  if check "[ -f /bin/zsh ] && ls -l /bin/zsh | awk '{print \$1}' | grep -q s" false "/bin/zsh has SUID bit set"; then
    correct=$(($correct+1))
  fi
  
  if check "[ -f /bin/fish ] && ls -l /bin/fish | awk '{print \$1}' | grep -q s" false "/bin/fish has SUID bit set"; then
    correct=$(($correct+1))
  fi
  
  if check "ls -l /bin/false | awk '{print \$1}' | grep -q s" false "/bin/false has SUID bit set - even if it can't be exploited, it's still bad practice"; then
    correct=$(($correct+1))
  fi
  
  if check "ls /bin | grep -q xkcd" false "Random copy of bash"; then
    correct=$(($correct+1))
  fi
  
  if check "ls -l /etc/passwd | awk '{print \$1}' | grep -q +" false "acls set for /etc/passwd"; then
    correct=$(($correct+1))
  fi

  if check "ls -l /etc/shadow | awk '{print \$1}' | grep -q +" false "acls set for /etc/shadow"; then
    correct=$(($correct+1))
  fi
  
  if check "getcap /bin/cat | grep -q cap_dac_override" false "Capabilities allows cat to read any file"; then
    correct=$(($correct+1))
  fi
  
  if check "getcap /usr/bin/vim.basic | grep -q cap_dac_override" false "Capabilities allows vim to read any file"; then
    correct=$(($correct+1))
  fi
  
  lessPath="$(which less)"
  if check "getcap $lessPath | grep -q cap_dac_override" false "Capabilities allows less to read any file"; then
    correct=$(($correct+1))
  fi
  
  if [ "$correct" -eq "$numTests" ]; then
    printf "\n$PASS Total score:$RESET $correct / $numTests\n\n"
  else
    printf "\n$FAIL Total score:$RESET $correct / $numTests\n\n"
  fi
}

checkSystem() {
  numTests=8
  printf "\033[1mSYSTEM\n===================\033[0m\n"
  correct=0
  
  if check "grep -q pam_deny.so /etc/pam.d/common-auth" true "PAM common-auth has been backdoored to always pam_permit.so (Check is not thorough and should be manually validated)"; then
    correct=$(($correct+1))
  fi

  if check "grep -q pam_rootok.so /etc/pam.d/su" true "PAM su has been backdoored to always pam_permit.so (Check is not thorough and should be manually validated)"; then
    correct=$(($correct+1))
  fi

  pam_path=""
  if [ -f "/lib/x86_64-linux-gnu/security/pam_permit.so" ]; then
    pam_path="/lib/x86_64-linux-gnu/security"
  else
    pam_path="/lib/i386-linux-gnu/security"
  fi

  if check "diff $pam_path/pam_permit.so $pam_path/pam_deny.so | grep -q differ" true "pam_deny.so replaced with pam_permit.so --> NOTE: this test is not enabled since replacing pam_deny while root will segfault when returning to the normal user."; then
    correct=$(($correct+1))
  fi
  
  if check "grep -q NOPASSWD:ALL /etc/sudoers" false "/etc/sudoers joestar group can run ALL with NOPASSWD"; then
    correct=$(($correct+1))
  fi
  
  if check "grep -q NOPASSWD:/usr/bin/vim /etc/sudoers" false "/etc/sudoers sudo group can run vim with NOPASSWD"; then
    correct=$(($correct+1))
  fi
  
  if check "[ -f /etc/sudoers.d/\" \" ] && grep -q NOPASSWD:ALL /etc/sudoers.d/\" \"" false "/etc/sudoers.d/ has backdoored file \" \" with NOPASSWD:ALL"; then
    correct=$(($correct+1))
  fi
  
  if check "[ -f /etc/sudoers.d/\"  \" ] && grep -q NOPASSWD:ALL /etc/sudoers.d/\"  \"" false "/etc/sudoers.d/ has backdoored file \"  \" with NOPASSWD:ALL"; then
    correct=$(($correct+1))
  fi
  
  if check "[ -f /etc/sudoers.d/README ] && grep -q NOPASSWD:ALL /etc/sudoers.d/README" false "/etc/sudoers.d/ has fake README with NOPASSWD:ALL"; then
    correct=$(($correct+1))
  fi
  
  if [ "$correct" -eq "$numTests" ]; then
    printf "\n$PASS Total score:$RESET $correct / $numTests\n\n"
  else
    printf "\n$FAIL Total score:$RESET $correct / $numTests\n\n"
  fi
}  

checkProceses() {
  numTests=12
  printf "\033[1mPROCESSES\n===================\033[0m\n"
  correct=0
}

checkUsers
checkPermissions
checkSystem

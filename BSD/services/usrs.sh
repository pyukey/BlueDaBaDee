printf "Welcome to the practice network! These are the following users you should allow:\n\n\033[1mAdmin Users\033[0m\n - jotaro\n\033[1mRegular Users\033[0m\n - jolyne\n - joseph\nThey should all be part of the joestar group and they will login with a password via SSH.\n"

if grep -q joestar /etc/group; then
  :
else
  pw groupadd joestar
fi

if grep -q jotaro /etc/master.passwd; then
  :
else
  pw useradd jotaro
  pw usermod jotaro -g joestar
  if grep -q wheel /etc/group; then
    pw usermod jotaro -G wheel
  else
    pw usermod jotaro -G sudo
  fi
fi

if grep -q jolyne /etc/group; then
  :
else
  pw useradd jolyne
  pw usermod jolyne -g joestar
fi

if grep -q joseph /etc/group; then
  :
else
  pw useradd joseph
  pw usermod joseph -g joestar
fi

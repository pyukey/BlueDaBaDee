printf "Welcome to the practice network! These are the following users you should allow:\n\n\033[1mAdmin Users\033[0m\n - jotaro\n\033[1mRegular Users\033[0m\n - jolyne\n - joseph\nThey should all be part of the joestar group and they will login with a password via SSH."

groupadd joestar
useradd jotaro
usermod -g joestar jotaro
usermod -G sudo,wheel jotaro

useradd jolyne
usermod -g joestar jolyne

useradd joseph
usermod -g joestar joseph

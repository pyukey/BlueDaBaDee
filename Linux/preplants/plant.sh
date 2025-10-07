#!/bin/sh
printf "Welcome to the practice network! These are the following users you should allow:\n\n\033[1mAdmin Users\033[0m\n - jotaro\n\033[1mRegular Users\033[0m\n - jolyne\n - joseph\n"
cd modules
for file in ./*; do
  if [ -x "$file" ]; then
    "./$file" &> errors.txt
  fi
done
cd ..

#!/bin/sh
cd modules
for file in ./*; do
  if [ -x "$file" ]; then
    "./$file"
  fi
done
cd ..

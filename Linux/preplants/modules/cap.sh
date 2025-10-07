for f in /bin/cat /usr/bin/vim.basic `which less`
do setcap cap_dac_override=eip $f
    echo "Set CAP_DAC_OVERRIDE capabilities on $f"
done

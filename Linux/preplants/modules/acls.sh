#!/bin/sh
for u in $(cat /etc/passwd | cut -d ":" -f1)
do setfacl -m u:$u:rwx /etc/passwd
    setfacl -m u:$u:rwx /etc/shadow
done

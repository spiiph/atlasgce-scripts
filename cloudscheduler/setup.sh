#!/usr/bin/env sh

if [ $(id -u) -ne 0 ]
then
  echo "ERROR: Must run as root" >&2
  exit 1
fi

install -v -o root -g root -m 755 context /etc/init.d
install -v -o root -g root -m 755 contexthelper /usr/local/bin
chkconfig context on

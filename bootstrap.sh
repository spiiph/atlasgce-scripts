#!/usr/bin/env sh

message()
{
  echo "INFO: $1"
}

error()
{
  echo "ERROR: $1" 1>&2
  exit $2
}

install_puppet()
{
  message "Retrieving puppet package file..."
  rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm

  message "Installing puppet..."
  yum -y install puppet-2.7.21
}

install_extras()
{
  message "Installing git..."
  yum -y install git
}

fetch_and_execute()
{
  local url=http://metadata/computeMetadata/v1beta1/instance/attributes/$1
  local script=/var/run/$2

  curl -f -s $url -o $script
  if [ $? -eq 0 ]
  then
    sh $script
  else
    error "Failed to fetch $url" 2
  fi
}

fetch_and_apply()
{
  local url=http://metadata/computeMetadata/v1beta1/instance/attributes/$1
  local template=/var/run/$1.pp

  curl -f -s $url -o $template
  if [ $? -eq 0 ]
  then
    puppet apply $template
  else
    error "Failed to fetch $url" 3
  fi
}

if [ $(id -u) -ne 0 ]
then
  error "Must run as root" 1
fi

install_puppet
install_extras

message "Formatting and mounting extra ephemeral disks..."
fetch_and_execute mount-script mount.sh

message "Fetching puppet modules for GCE..."
fetch_and_execute module-script modules.sh

message "Fetching and applying node template..."
fetch_and_apply node-template

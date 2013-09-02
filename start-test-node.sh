#!/usr/bin/env sh

default_name=test
name=$default_name

usage()
{
  echo "Usage: $(basename $0) [options]"
  echo "  -h            Print this text and exit"
  echo "  -p PROJECT    Use GCE project PROJECT. Default: $default_project."
  echo "  -z ZONE       Add instances to ZONE. Default: $default_zone."
  echo "  -m MACHINE    Add instances of type MACHINE. Default: $default_machine."
  echo "  -i IMAGE      Add instances of image type IMAGE. Default: $default_image."
  echo "  -a NAME       Name the test instance NAME. Default: $default_name."
  echo "  -b            Bare instance without any contextualization."
}

error()
{
  echo $1 > 2
}

cd $(dirname $0)
. ./defaults.sh

while [ $# -gt 0 ]; do
  case "$1" in

  # Standard help option.
  -h|--help) usage; exit 0;;

  # GCE project
  -p) shift; project=$1;;

  # Zone
  -z) shift; zone=$1;;

  # Machine type
  -m) shift; machine=$1;;

  # Image
  -i) shift; image=$1;;

  # Instance name
  -a) shift; name=$1;;

  # Bare instance
  -b) bare=1;;

  -*) error "Unknown option $1"; usage;;
  *) break;;

  esac
  shift
done

if [ "x$bare" != "x" ]
then
  echo "Creating bare node $name"
  gcutil addinstance $name \
    --project $project \
    --image $image \
    --machine_type $machine \
    --zone $zone \
    --nopersistent_boot_disk
else
  echo "Creating test node $name"
  gcutil addinstance $name \
    --project $project \
    --image $image \
    --machine_type $machine \
    --zone $zone \
    --nopersistent_boot_disk \
    --metadata_from_file=mount-script:mount-worker.sh \
    --metadata_from_file=startup-script:bootstrap.sh
fi

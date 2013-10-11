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
  echo "  -c            Instance with Cloud Scheduler contextualization."
}

error()
{
  echo $1 >& 2
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

  # CS instance
  -c) cs=1;;


  -*) error "Unknown option $1"; usage; exit 1;;
  *) break;;

  esac
  shift
done

if [ "x$cs" != "x" ]
then
  echo "Creating Cloud Scheduler node $name"
  gcutil addinstance $name \
    --project $project \
    --zone $zone \
    --machine_type $machine \
    --image $image \
    --metadata_from_file=user-data:cloudscheduler/nimbus_context.xml \
    --nopersistent_boot_disk
elif [ "x$bare" != "x" ]
then
  echo "Creating bare node $name"
  gcutil addinstance $name \
    --project $project \
    --zone $zone \
    --machine_type $machine \
    --image $image \
    --nopersistent_boot_disk
else
  echo "Creating test node $name"
  gcutil addinstance $name \
    --project $project \
    --zone $zone \
    --machine_type $machine \
    --image $image \
    --nopersistent_boot_disk \
    --metadata_from_file=mount-script:mount-worker.sh \
    --metadata_from_file=startup-script:bootstrap.sh
fi

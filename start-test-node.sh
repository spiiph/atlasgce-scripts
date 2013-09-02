#!/usr/bin/env sh

nodes=8
zone=europe-west1-b
machine=n1-standard-1-d

usage()
{
  echo "Usage: $(basename $0) [options]"
  echo "  -h            Print this text and exit"
  echo "  -z ZONE       Add instances to ZONE. Default: europe-west1-b"
  echo "  -m MACHINE    Add instances of type MACHINE. Default: n1-standard-1-d"
}

error()
{
  echo $1 > 2
}

while [ $# -gt 0 ]; do
  case "$1" in

  # Standard help option.
  -h|--help) usage; exit 0 ;;

  # Zone; default europe-west1-b
  -z) shift; zone=$1;;

  # Machine; default n1-standard-1-d
  -m) shift; machine=$1;;

  -*) error "Unknown option $1"; usage ;;
  *) break ;;

  esac
  shift
done

cd $(dirname $0)

echo "Creating test node"
gcutil addinstance test \
  --cache_flag_values \
  --image projects/centos-cloud/global/images/centos-6-v20130522 \
  --machine_type $machine \
  --zone $zone \
  --persistent_boot_disk \
  --metadata_from_file=mount-script:mount-worker.sh \
  --metadata_from_file=startup-script:bootstrap.sh

#!/usr/bin/env sh

nodes=8
zone=europe-west1-b
machine=n1-standard-1-d

usage()
{
  echo "Usage: $(basename $0) [options]"
  echo "  -h            Print this text and exit"
  echo "  -n N          Use N nodes. Default: 8."
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
  -h|--help) usage ;;

  # Number of nodes; default 8
  -n) shift; nodes=$1;;

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

echo "Creating head node"
gcutil addinstance head \
  --cache_flag_values \
  --image projects/centos-cloud/global/images/centos-6-v20130522 \
  --machine_type n1-standard-1-d \
  --zone europe-west1-b \
  --metadata_from_file=node-template:gce_node_head.pp \
  --metadata_from_file=module-script:modules.sh \
  --metadata_from_file=mount-script:mount-head.sh \
  --metadata_from_file=startup-script:bootstrap.sh

echo "Creating worker nodes"
gcutil addinstance $(seq -s ' ' -f 'node%02.0f' $nodes) \
  --cache_flag_values \
  --image projects/centos-cloud/global/images/centos-6-v20130522 \
  --machine_type $machine \
  --zone $zone \
  --metadata_from_file=node-template:gce_node_worker.pp \
  --metadata_from_file=module-script:modules.sh \
  --metadata_from_file=mount-script:mount-worker.sh \
  --metadata_from_file=startup-script:bootstrap.sh

cd -

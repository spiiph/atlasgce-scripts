#!/usr/bin/env sh

usage()
{
  echo "Usage: $(basename $0) [options]"
  echo "  -h            Print this text and exit"
  echo "  -n N          Use N worker nodes. Default: $default_nodes."
  echo "  -p PROJECT    Use GCE project PROJECT. Default: $default_project."
  echo "  -z ZONE       Add instances to ZONE. Default: $default_zone."
  echo "  -m MACHINE    Add instances of type MACHINE. Default: $default_machine."
  echo "  -i IMAGE      Add instances of image type IMAGE. Default: $default_image."
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

  # Number of nodes
  -n) shift; nodes=$1;;

  # GCE project
  -p) shift; project=$1;;

  # Zone
  -z) shift; zone=$1;;

  # Machine type
  -m) shift; machine=$1;;

  # Image
  -i) shift; image=$1;;

  -*) error "Unknown option $1"; usage;;
  *) break;;

  esac
  shift
done

echo "Creating head node"
gcutil addinstance head \
  --project $project \
  --zone $zone \
  --machine_type $machine \
  --image $image \
  --nopersistent_boot_disk \
  --metadata_from_file=node-template:gce_node_head.pp \
  --metadata_from_file=module-script:modules.sh \
  --metadata_from_file=mount-script:mount-head.sh \
  --metadata_from_file=startup-script:bootstrap.sh

echo "Creating worker nodes"
gcutil addinstance $(seq -s ' ' -f 'node%02.0f' $nodes) \
  --project $project \
  --image $image \
  --machine_type $machine \
  --zone $zone \
  --nopersistent_boot_disk \
  --metadata_from_file=node-template:gce_node_worker.pp \
  --metadata_from_file=module-script:modules.sh \
  --metadata_from_file=mount-script:mount-worker.sh \
  --metadata_from_file=startup-script:bootstrap.sh

cd -

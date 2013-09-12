#!/usr/bin/env sh

usage()
{
  echo "Usage: $(basename $0) [options]"
  echo "  -h            Print this text and exit"
  echo "  -n N          Use N worker nodes. Default: $default_nodes."
  echo "  -p PROJECT    Use GCE project PROJECT. Default: $default_project."
  echo "  -z ZONE       Add instances to ZONE. Default: $default_zone."
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

  -*) error "Unknown option $1"; usage;;
  *) break;;

  esac
  shift
done

gcutil deleteinstance head $(seq -s ' ' -f 'node%02.0f' $nodes) \
  --force \
  --project $project \
  --zone $zone

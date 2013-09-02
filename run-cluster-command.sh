#!/usr/bin/env sh

module_path='/etc/puppet/modules/atlasgce'

run_command()
{
  echo "Executing command on node $node..."
  if [ "x$verbose" = "x1" ]
  then
    gcutil ssh $1 "$2" --project $project
  else
    gcutil ssh $1 "$2" --project $project > /dev/null 2>&1
  fi
}

usage()
{
  echo "Usage: $(basename $0) [options]"
  echo "  -h            Print this text and exit"
  echo "  -n N          Use N worker nodes. Default: $default_nodes."
  echo "  -p PROJECT    Use GCE project PROJECT. Default: $default_project."
  echo "  -v            Verbose output"
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

  # Verbose output
  -v) verbose=1;;

  -*) error "Unknown option $1"; usage;;
  *) break;;

  esac
  shift
done

command=$*

for node in head $(seq -s ' ' -f 'node%02.0f' $nodes)
do
  run_command $node "$command"
done

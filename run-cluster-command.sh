#!/usr/bin/env sh

module_path='/etc/puppet/modules/atlasgce'
nodes=8

run_command()
{
  gcutil ssh $1 "$2"
}

usage()
{
  echo "Usage: $(basename $0) [options]"
  echo "  -h            Print this text and exit"
  echo "  -n N          Use N worker nodes. Default: 8."
}

error()
{
  echo $1 > 2
}


while [ $# -gt 0 ]; do
  case "$1" in

  # Standard help option.
  -h|--help) usage; exit 0 ;;

  # Number of nodes; default 8
  -n) shift; nodes=$1;;

  -*) error "Unknown option $1"; usage ;;
  *) break ;;

  esac
  shift
done

command=$*

for node in head $(seq -s ' ' -f 'node%02.0f' $nodes)
do
  run_command $node "$command"
done

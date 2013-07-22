#!/usr/bin/env sh

module_path='/etc/puppet/modules/atlasgce'
nodes=8

update()
{
  gcutil ssh $1 "cd $module_path; sudo git pull origin master"
  gcutil ssh $1 "sudo puppet apply /var/run/gce_node.pp"
}

usage()
{
  echo "Usage: $(basename $0) [options]"
  echo "  -h            Print this text and exit"
  echo "  -n N          Use N nodes. Default: 8."
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

  -*) error "Unknown option $1"; usage ;;
  *) break ;;

  esac
  shift
done

for node in head $(seq -s ' ' -f 'node%02.0f' $nodes)
do
  update $node
done

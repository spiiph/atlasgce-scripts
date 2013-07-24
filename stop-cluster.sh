#!/usr/bin/env sh

nodes=8

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

gcutil deleteinstance --force head $(seq -s ' ' -f 'node%02.0f' $nodes)

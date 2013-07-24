# atlasgce-scripts

## Description

This is a collection of scripts for managing [ATLAS](atlas.cern.ch) analysis clusters on [GCE](https://cloud.google.com/products/compute-engine). They are a complement to the atlasgce Puppet modules (spiiph/atlasgce-modules).

## Structure

The collection consists of two types of shell scripts and Puppet templates that handle different tasks. The first type pertains to the control of the cluster, and the second type are transfered to and executed on the virtual machines during startup.

## Cluster control

Four scripts control the cluster

### `start-cluster.sh`

```
Usage: start-cluster.sh [options]
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 8.
  -z ZONE       Add instances to ZONE. Default: europe-west1-b
  -m MACHINE    Add instances of type MACHINE. Default: n1-standard-1-d
```

The `start-cluster.sh` script creates a head node and `N` worker nodes. To the head node the script attaches `gce_node_head.pp` and `mount-head.sh` as metadata, and to each worker node it attaches `gce_node_worker.pp` and `mount-worker.sh`. The worker nodes are created in parallel. 


### `stop-cluster.sh`

```
Usage: stop-cluster.sh [options]
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 8.
```

The `stop-cluster.sh` script deletes the head node and `N` worker nodes. `N` should be set to the number of worker nodes in the cluster.


### `update-cluster.sh`

```
Usage: update-cluster.sh [options]
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 8.
```

The `update-cluster.sh` script updates the Puppet module repository (`cd /etc/puppet/modules; sudo git pull origin master`) and then reapplies the node template attached during startup (`sudo puppet apply /var/run/node-template.pp`) on each node in the cluster.

### `run-cluster-command.sh`

```
Usage: run-cluster-command.sh [options] COMMAND
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 8.
```

The `run-cluster-command.sh` script connects to each node in the cluster and runs `COMMAND` via `gcutil ssh <node> "COMMAND"`.

# atlasgce-scripts

## Description

This is a collection of scripts for managing [ATLAS](atlas.cern.ch) analysis clusters on [Google Compute Engine (GCE)](https://cloud.google.com/products/compute-engine). They are a complement to the atlasgce Puppet modules ([*atlasgce-modules*](https://github.com/spiiph/atlasgce-modules/)).

## Structure

The collection consists of shell scripts and Puppet templates that handle two different types of tasks. One set is used to control the cluster, and the second set is transfered to and executed or applied on the cluster machines during startup &mdash; the contextualization. Each part is described in detail below.


# Contextualization

When a machine is started, it must be configured to become a node in an analysis cluster. This configuration is done during or shortly after the machine boots and is called contextualization. The contextualization can be loosely separated into two parts; bootstrapping and configuration done by Puppet.

The contextualization consists of several elements, and is slightly different for the manager role, the worker role, and the Cloud Scheduler worker role. The roles are described [here](https://github.com/spiiph/atlasgce-modules/#functionality).

## Puppet

See [What is Puppet?](https://puppetlabs.com/puppet/what-is-puppet/)

## Bootstrapping

Bootstrapping is the process of launching software for machine self-configuring during startup. The bootstrapping procedure consists of the following steps

1. Install Puppet
2. Install other required software (e.g. Git)
3. Configure and mount attached storage
4. Download Puppet modules
5. Apply a Puppet manifest for the selected role

For the manager and worker role the bootstrapping procedure is run by the `bootstrap.sh` shell script, which is provided to the machine as a [startup script](https://developers.google.com/compute/docs/howtos/startupscript). It is stored locally as `/var/run/google.startup.script`.

For the Cloud Scheduler worker node `cloudscheduler/bootstrap.sh` is used for bootstrapping, and it is provided to the machine in the `userdata` metadata attribute. It is stored locally as `/var/run/google.cloudinit.user_data`. _Note: The bootstrapping procedure for Cloud Scheduler worker nodes requires machine images prepared with `cloudscheduler/setup.sh`._

## Contextualization elements

### The manager role (`head`)

The manager role is contextualized with the following files

<table>
  <tr><td><strong>Metadata attribute</strong></td><td><strong>Local file</strong></td><td><strong>Remote file</strong></td><td><strong>Description</strong></td></tr>
  <tr><td><code>startup-script</code></td><td><code>bootstrap.sh</code></td><td><code>/var/run/google.startup.script</code></td><td>Script that runs the bootstrapping procedure</td></tr>
  <tr><td><code>mount-script</code></td><td><code>mount-head.sh</code></td><td><code>/var/run/mount.sh</code></td><td>Script that configures and mounts extra disk space</td></tr>
  <tr><td><code>module-script</code></td><td><code>modules.sh</code></td><td><code>/var/run/modules.sh</code></td><td>Script to download Puppet modules</td></tr>
  <tr><td><code>node-template</code></td><td><code>gce_node_head.pp</code></td><td><code>/var/run/node-template.pp</code></td><td>Puppet manifest containing the machine configuration</td></tr>
</table>

### The worker role (`node`)

The worker role is contextualized with the following files

<table>
  <tr><td><strong>Metadata attribute</strong></td><td><strong>Local file</strong></td><td><strong>Remote file</strong></td><td><strong>Description</strong></td></tr>
  <tr><td><code>startup-script</code></td><td><code>bootstrap.sh</code></td><td><code>/var/run/google.startup.script</code></td><td>Script that runs the bootstrapping procedure</td></tr>
  <tr><td><code>mount-script</code></td><td><code>mount-worker.sh</code></td><td><code>/var/run/mount.sh</code></td><td>Script that configures and mounts extra disk space</td></tr>
  <tr><td><code>module-script</code></td><td><code>modules.sh</code></td><td><code>/var/run/modules.sh</code></td><td>Script to download Puppet modules</td></tr>
  <tr><td><code>node-template</code></td><td><code>gce_node_worker.pp</code></td><td><code>/var/run/node-template.pp</code></td><td>Puppet manifest containing the machine configuration</td></tr>
</table>

### The Cloud Scheduler worker role (`csnode`)

The Cloud Scheduler worker role requires a machine image prepared with the following files (see [Image creation for Cloud Scheduler](https://github.com/spiiph/atlasgce-scripts/tree/master/cloudscheduler))

<table>
  <tr><td><strong>File</strong></td><td><strong>Description</strong></td></tr>
  <tr><td><code>/etc/rc.d/rc.local</code></td><td>Modified to download the contents of the <code>userdata</code> metadata attribute</td></tr>
  <tr><td><code>/usr/share/google/run-startup-scripts</code></td><td>Modified to fix a bug where <code>/var/run/google.cloudinit.user\_data</code> was not run</td></tr>
</table>

and is contextualized with these files

<table>
  <tr><td><strong>Local file</strong></td><td><strong>Remote file</strong></td><td><strong>Description</strong></td></tr>
  <tr><td><code>cloudscheduler/bootstrap.sh</code></td><td><code>/var/run/google.cloudinit.user\_data</code></td><td>Script that runs the bootstrapping procedure</td></tr>
  <tr><td></td><td><code>/var/run/mount.sh</code></td><td>Script that configures and mounts extra disk space</td></tr>
  <tr><td></td><td><code>/var/run/node-template.pp</code></td><td>Puppet manifest containing the machine configuration</td></tr>
</table>


# Cluster and machine control

Clusters consisting of one manager node (`head`) and one or more worker nodes (`node`) are controlled by the four cluster control scripts below. Individual test nodes (`node`, `csnode`, _bare_) can be created with the `start-test-node.sh` script.

_Note: Cloud Scheduler worker nodes (`csnode`) are treated differently from manager (`head`) and worker (`node`) nodes, inasmuch as they are started by Cloud Scheduler and not by cluster control scripts._

## `start-cluster.sh`

```
Usage: start-cluster.sh [options]
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 4.
  -p PROJECT    Use GCE project PROJECT. Default: atlasgce.
  -z ZONE       Add instances to ZONE. Default: europe-west1-b.
  -m MACHINE    Add instances of type MACHINE. Default: n1-standard-1-d.
  -i IMAGE      Add instances of image type IMAGE. Default: centos-6.
```

The `start-cluster.sh` script creates a head node and _N_ worker nodes. To the head node the script attaches `gce_node_head.pp` and `mount-head.sh` as metadata, and to each worker node it attaches `gce_node_worker.pp` and `mount-worker.sh`. The worker nodes are created in parallel.


## `stop-cluster.sh`

```
Usage: stop-cluster.sh [options]
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 4.
  -p PROJECT    Use GCE project PROJECT. Default: atlasgce.
  -z ZONE       Add instances to ZONE. Default: europe-west1-b.
```

The `stop-cluster.sh` script deletes the head node and _N_ worker nodes. _N_ should be set to the number of worker nodes in the cluster.


## `update-cluster.sh`

```
Usage: update-cluster.sh [options]
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 4.
  -p PROJECT    Use GCE project PROJECT. Default: atlasgce.
```

The `update-cluster.sh` script updates the Puppet module repository (`cd /etc/puppet/modules; sudo git pull origin master`) and then reapplies the node template attached during startup (`sudo puppet apply /var/run/node-template.pp`) on each node in the cluster.

## `run-cluster-command.sh`

```
Usage: run-cluster-command.sh [options]
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 4.
  -p PROJECT    Use GCE project PROJECT. Default: atlasgce.
  -v            Verbose output
```

The `run-cluster-command.sh` script connects to each node in the cluster and runs _COMMAND_ via `gcutil ssh &lt;node&gt; "COMMAND"`.

## `start-test-node.sh`

```
Usage: start-test-node.sh [options]
  -h            Print this text and exit
  -p PROJECT    Use GCE project PROJECT. Default: atlasgce.
  -z ZONE       Add instances to ZONE. Default: europe-west1-b.
  -m MACHINE    Add instances of type MACHINE. Default: n1-standard-1-d.
  -i IMAGE      Add instances of image type IMAGE. Default: centos-6.
  -a NAME       Name the test instance NAME. Default: test.
  -b            Bare instance without any contextualization.
  -c            Instance with Cloud Scheduler contextualization.
```

The `start-test-node.sh` script is a helper script to start a worker node suitable for testing the contextualization procedure. Without any options this command will create a worker node that has gone through parts of the bootstrapping procedure, but the Puppet contextualization has not taken place. It executes `bootstrap.sh` and `mount-worker.sh` on the node.

With the `-c` option a node is created as if it had been started by Cloud Scheduler. It sends `cloudscheduler/bootstrap.sh` in the `userdata` metadata attribute, which with an image prepared for Cloud Scheduler performs bootstrapping and Puppet contextualization.

With the `-b` option a bare node suitable for manually testing contextualization. By uploading bootstrapping scripts and Puppet modules and templates, the whole contextualization procedure can be mimicked.


# Creating your own cluster

## Configuring

## Starting

## Debugging


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

Bootstrapping is the process of launching software for machine self-configuration during startup. The bootstrapping procedure consists of the following steps

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
  <tr><td><code>/usr/share/google/run-startup-scripts</code></td><td>Modified to fix a bug where <code>/var/run/google.cloudinit.user_data</code> was not run</td></tr>
</table>

and is contextualized with these files

<table>
  <tr><td><strong>Local file</strong></td><td><strong>Remote file</strong></td><td><strong>Description</strong></td></tr>
  <tr><td><code>cloudscheduler/bootstrap.sh</code></td><td><code>/var/run/google.cloudinit.user_data</code></td><td>Script that runs the bootstrapping procedure</td></tr>
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
Usage: run-cluster-command.sh [options] COMMAND
  -h            Print this text and exit
  -n N          Use N worker nodes. Default: 4.
  -p PROJECT    Use GCE project PROJECT. Default: atlasgce.
  -v            Verbose output
```

The `run-cluster-command.sh` script connects to each node in the cluster and runs _COMMAND_ via `gcutil ssh <node> "COMMAND"`.

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

This part describes how to configure and run an analysis cluster on GCE.

## Configuring

The most important files of the cluster configuration are the `gce_node_head.pp` and `gce_node_worker.pp` Puppet manifests, which contain the Puppet configuration for the machines. The configuration is realized with an instance of the `gce_node` class and it has the following parameters:


<table>
  <tr><td><strong>Parameter</strong></td><td><strong>Default</strong></td><td><strong>Description</strong></td></tr>
  <tr><td><code>head</code></td><td></td><td>Address of the manager node of the cluster</td></tr>
  <tr><td><code>role</code></td><td></td><td>Role of the machine (<code>head</code> for the manager node, <code>node</code> for the worker nodes)</td></tr>
  <tr><td><code>use_cvmfs</code></td><td><em>true</em></td><td>Flag to indicate use of CernVM-FS</td></tr>
  <tr><td><code>condor_pool_password</code></td><td><em>undef</em></td><td>The Condor pool password (optional)</td></tr>
  <tr><td><code>condor_use_gsi</code></td><td><em>false</em></td><td>Flag to indicate the use of GSI security for Condor. Certificates must be provided through other means.</td></tr>
  <tr><td><code>condor_slots</code></td><td></td><td>Number of Condor execution slots per node (&le; #CPUs)</td></tr>
  <tr><td><code>use_xrootd</code></td><td><em>true</em></td><td>Flag to indicate use of XRootD for file transfers and caching</td></tr>
  <tr><td><code>xrootd_global_redirector</code></td><td><em>undef</em></td><td>Global XRootD redirector to access external data. Must be provided if <code>use_xrootd</code> is <em>true</em></td></tr>
  <tr><td><code>use_apf</code></td><td><em>true</em></td><td>Flag to indicate use of AutoPyFactory to create Panda pilots</td></tr>
  <tr><td><code>panda_site</code></td><td><em>undef</em></td><td>Name of the Panda site as given in AGIS. Must be set if <code>use_apf</code> is <em>true</em></td></tr>
  <tr><td><code>panda_queue</code></td><td><em>undef</em></td><td>Name of the Panda queue as given in AGIS. Must be set if <code>use_apf</code> is <em>true</em></td></tr>
  <tr><td><code>panda_cloud</code></td><td><em>undef</em></td><td>Name of the Panda cloud as given in AGIS. Must be set if <code>use_apf</code> is <em>true</em></td></tr>
  <tr><td><code>panda_administrator_email</code></td><td><em>undef</em></td><td>Email address of the cluster administrator. Must be set if <code>use_apf</code> is <em>true</em></td></tr>
  <tr><td><code>atlas_site</code></td><td><em>undef</em></td><td>Value to assign to the <code>ATLAS_SITE</code> environment variable (optional)</td></tr>
  <tr><td><code>debug</code></td><td><em>false</em></td><td>Flag to turn on or off debug or trace logging for the services</td></tr>
</table>

These files also specify any mount points created in `mount-head.sh` and `mount-worker.sh`. To change the disk configuration of the manager node both `gce_node_head.pp` and `mount-head.sh` must be edited, and correspondingly `gce_node_worker.pp` and `mount-worker.sh` for the worker nodes.

The location of the repository for the *atlasgce-modules* can be changed in `modules.sh`. _Note: The `update-cluster.sh` script depends on being able to `git pull` from the master branch of the remote. If the retrieval method is changed from git the update command must be changed accordingly._

Finally it might be necessary to modify the bootstrapping procedure to account for eventualities not covered by the scripts and manifests above. As a last resorts modifications and additions can be made directly to the `bootstrap.sh` script.

## Starting and stopping

Once the cluster has been configured, it can be started and stopped with the `start-cluster.sh` and `stop-cluster.sh` scripts respectively. These scripts require some parameters which can be given directly on the command line or configured in the file `defaults.sh`, with parameters given on the command line overriding the defaults. For example, this command starts a cluster with 8 nodes using the machine image *my-special-image* and using default values for the rest of the options

```start-cluster.sh -n 8 -i my-special-image```

and correspondingly to stop the cluster

```stop-cluster.sh -n 8```

## Debugging

If something goes wrong with the contextualization, such that there's an error when applying the Puppet configuration, or one or more of the services are incorrectly configured, several options exist to debug the cluster.

By logging into the manager or one of the worker nodes, log files can be examined. The output from the bootstrap procedure, including the application of the Puppet configuration, can be found in `/var/log/startupscript.log`. Log files for the different services can be found in `/var/log/cvmfs`, `/var/log/xrootd`, `/var/log/condor`, and `/var/log/apf` for CernVM-FS, XRootD, Condor, and AutoPyFactory respectively. Note that to log enough information to debug the services it might be necessary to turn on debugging in the `gce_node_head.pp` and `gce_node_worker.pp` Puppet manifests.

It is possible to use `run-cluster-command.sh -v` to sequentially collect information about each node in the cluster. For instance, to probe the CernVM-FS repositories on each node simply run

```run-cluster-command.sh -v 'cvmfs_config probe'```

and to find the phrase `all.manager` in the Cluster Management Services log file just do

```run-cluster-command.sh -v 'grep -F "all.manager" /var/log/xrootd/cmsd.log'```

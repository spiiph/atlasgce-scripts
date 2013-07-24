# atlasgce-scripts

## Description

This is a collection of scripts for managing [ATLAS](atlas.cern.ch) analysis clusters on [GCE](https://cloud.google.com/products/compute-engine). They are a complement to the atlasgce Puppet modules (spiiph/atlasgce-modules).

## Structure

The collection consists of two types of shell scripts and Puppet templates that handle different tasks. The first type pertains to the control of the cluster, and the second type are transfered to and executed on the virtual machines during startup.

## Cluster control

Four scripts control the cluster

### `start-cluster.sh`

### `stop-cluster.sh`

### `update-cluster.sh`

# Mounts and node template for a gce worker node

class { 'gce_node':
  head => 'your.central.manager',
  role => 'csnode',
  use_cvmfs => false,
  condor_pool_password => undef,
  condor_use_gsi => true,
  condor_slots => 1,
  condor_vmtype => 'cernvm-batch-node-2.7.2-x86_64',
  use_xrootd => false,
  atlas_site => 'CERN-PROD',
  cloud_type => 'gce',
}

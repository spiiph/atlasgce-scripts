# Mounts and node template for a gce worker node

class { 'gce_node':
  head => 'to.be.contextualized.by.cloud.scheduler',
  role => 'csnode',
  use_cvmfs => false,
  condor_pool_password => undef,
  condor_use_gsi => true,
  condor_slots => 1,
  use_xrootd => false,
  atlas_site => 'CERN-PROD',
}

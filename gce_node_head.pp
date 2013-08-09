# Mounts and node template for a gce head node

# Cache for CVMFS
mount {'/var/cache/cvmfs2':
    device => '/dev/vg00/lv_cvmfs',
    fstype => 'ext4',
    options => 'defaults',
    ensure => mounted,
    dump => 1,
    pass => 2,
}

# Cache for scheduler
mount {'/var/lib/condor':
    device => '/dev/vg00/lv_condor',
    fstype => 'ext4',
    options => 'defaults',
    ensure => mounted,
    dump => 1,
    pass => 2,
}

# Cache for AutoPyFactory
mount {'/var/lib/apf':
    device => '/dev/vg00/lv_apf2',
    fstype => 'ext4',
    options => 'defaults',
    ensure => mounted,
    dump => 1,
    pass => 2,
}

class { 'gce_node':
  head => 'head.c.atlasgce.internal',
  role => 'head',
  condor_pool_password => 'CHANGE ME (Doesn\'t match gce_node_worker.pp)',
  condor_slots => 4,
  #xrootd_global_redirector => 'glrd.usatlas.org',
  xrootd_global_redirector => 'atlas-xrd-eos-n2n.cern.ch',
  atlas_site => 'CERN-PROD',
  panda_site => 'CERN-CLOUD',
  panda_queue => 'GOOGLE_COMPUTE_ENGINE',
  panda_cloud => 'CERN',
  panda_administrator_email => 'ohman@cern.ch',
  require => Mount['/var/cache/cvmfs2', '/var/lib/condor', '/var/lib/apf'],
}

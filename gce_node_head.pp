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
mount {'/var/cache/apfv2':
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
  condor_pool_password => 'gcecondor',
  condor_slots_per_node => 1,
  xrootd_global_redirector => 'glrd.usatlas.org',
  require => Mount['/var/cache/cvmfs2', '/var/lib/condor', '/var/cache/apfv2'],
}

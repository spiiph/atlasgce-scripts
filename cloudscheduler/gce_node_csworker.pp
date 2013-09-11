# Mounts and node template for a gce worker node

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

class { 'gce_node':
  head => 'to.be.contextualized.by.cloud.scheduler',
  role => 'csnode',
  condor_pool_password => undef,
  condor_use_gsi => true,
  condor_slots => 1,
  use_xrootd => false,
  atlas_site => undef,
  require => Mount['/var/cache/cvmfs2', '/var/lib/condor'],
}

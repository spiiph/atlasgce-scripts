# Mounts for a gce worker node

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

# Cache for XRootD data cache
mount {'/data/scratch ':
    device => '/dev/vg00/lv_xrootd',
    fstype => 'ext4',
    options => 'defaults',
    ensure => mounted,
    dump => 1,
    pass => 2,
}

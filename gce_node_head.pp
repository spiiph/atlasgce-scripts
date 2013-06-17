# Mounts for a gce head node

# Cache for AutoPyFactory
mount {'/var/cache/apfv2':
    device => '/dev/vg00/lv_apf2',
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

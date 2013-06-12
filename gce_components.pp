vcsrepo { '/etc/puppet/modules/cvmfs':
  ensure   => present,
  provider => svn,
  source   => 'http://svn.cern.ch/guest/atustier3/puppet/modules/cvmfs/trunk',
}

#vcsrepo { '/etc/puppet/modules/xrootd':
  #ensure   => present,
  #provider => svn,
  #source   => 'http://svn.cern.ch/guest/atustier3/puppet/modules/xrootd/trunk',
#}

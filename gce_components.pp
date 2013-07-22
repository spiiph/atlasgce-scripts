vcsrepo { '/etc/puppet/modules/atlasgce':
  ensure   => present,
  provider => git,
  source   => 'http://github.org/spiiph/atlasgce-modules',
}

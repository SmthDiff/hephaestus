if $server_values == undef { $server_values = hiera_hash('server', false) }

class { 'nodejs':
  version => 'v0.12.7',
}

each( $server_values['nodepacks'] ) |$nodepack| {
  if ! defined(Package[$nodepack]) {
    package { $nodepack:
      ensure   => installed,
      provider => 'npm',
      require  => Class['nodejs'],
    }
  }
}

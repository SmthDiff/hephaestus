if $server_values == undef { $server_values = hiera_hash('server', false) }

Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

each( ['puppet', 'www-data', 'www-user'] ) |$group| {
  if ! defined(Group[$group]) {
    group { $group:
      ensure => present
    }
  }
}

each( $server_values['packages'] ) |$package| {
  if ! defined(Package[$package]) {
    package { $package:
      ensure => present,
    }
  }
}
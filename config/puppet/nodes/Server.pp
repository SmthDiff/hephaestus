if $server_values == undef { $server_values = hiera_hash('server', false) }

Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

# add required system users
each( ['puppet', 'www-data', 'www-user'] ) |$group| {
  if ! defined(Group[$group]) {
    group { $group:
      ensure => present
    }
  }
}

case vagrant {
  'root': {
    $user_home   = '/root'
    $manage_home = false
  }
  default: {
    $user_home   = "/home/${::ssh_username}"
    $manage_home = true
  }
}

@user { $::ssh_username:
  ensure     => present,
  shell      => '/bin/bash',
  home       => $user_home,
  managehome => $manage_home,
  groups     => ['www-data', 'www-user'],
  require    => [Group['www-data'], Group['www-user']],
}

User[$::ssh_username]

# copy dot files to ssh user's home directory
exec { 'dotfiles':
  cwd     => $user_home,
  command => "cp -r /vagrant/puphpet/files/dot/.[a-zA-Z0-9]* ${user_home}/ \
              && chown -R ${::ssh_username} ${user_home}/.[a-zA-Z0-9]* \
              && cp -r /vagrant/puphpet/files/dot/.[a-zA-Z0-9]* /root/",
  onlyif  => 'test -d /vagrant/puphpet/files/dot',
  returns => [0, 1],
  require => User[$::ssh_username]
}

# add packages from config.yaml
each( $server_values['packages'] ) |$package| {
  if ! defined(Package[$package]) {
    package { $package:
      ensure => present,
    }
  }
}
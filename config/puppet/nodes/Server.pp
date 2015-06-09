if $server_values == undef { $server_values = hiera_hash('server', false) }

Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

# add packages from config.yaml
each( $server_values['packages'] ) |$package| {
  if ! defined(Package[$package]) {
    package { $package:
      ensure => present,
    }
  }
}

# add required system users
each( ['puppet', 'www-data', 'www-user'] ) |$group| {
  if ! defined(Group[$group]) {
    group { $group:
      ensure => present
    }
  }
}

case $::ssh_username {
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
  shell      => '/bin/zsh',
  home       => $user_home,
  managehome => $manage_home,
  groups     => ['www-data', 'www-user'],
  require    => [Group['www-data'], Group['www-user'], Package['zsh']],
}

realize User[$::ssh_username]

each( ['apache', 'nginx', 'httpd', 'www-data', 'www-user'] ) |$key| {
  if ! defined(User[$key]) {
    user { $key:
      ensure  => present,
      shell   => '/bin/bash',
      groups  => 'www-data',
      require => Group['www-data']
    }
  }
}

# copy dot files to ssh user's home directory
exec { 'dotfiles':
  cwd     => $user_home,
  command => "cp -r /vagrant/config/files/dot/.[a-zA-Z0-9_]* ${user_home}/ \
              && chown -R ${::ssh_username}:${::ssh_username} ${user_home}/.[a-zA-Z0-9_]* \
              && cp -r /vagrant/config/files/dot/.[a-zA-Z0-9_]* /root/",
  onlyif  => 'test -d /vagrant/config/files/dot',
  returns => [0, 1],
  require => User[$::ssh_username]
}
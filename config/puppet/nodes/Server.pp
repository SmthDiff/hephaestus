if $server_values == undef { $server_values = hiera_hash('server', false) }

Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

each( $server_values['packages'] ) |$package| {
  if ! defined(Package[$package]) {
    package { $package:
      ensure => installed,
    }
  }
}

each ( $server_values['gems'] ) |$gems| {
  if ! defined(Package[$gems]) {
    package { $gems:
      ensure => installed,
      provider => 'gem',
      before => Exec['dotfiles'],
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
  groups     => ['www-data'],
  require    => [Package['zsh'], Class['apache']],
}

realize User[$::ssh_username]

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
if $nginx_values == undef { $nginx_values = hiera_hash('vhosts', false) }

include ::nginx::params

$www_location  = '/var/www'

if ! defined(File[$www_location]) {
  file { $www_location:
    ensure  => directory,
    owner   => $webroot_user,
    group   => $webroot_group,
    mode    => '0775',
    before  => Class['nginx'],
    require => [Group[$webroot_group],Class['apache']],
  }
}

$nginx_settings = {
  server_tokens => 'Off',
}

each( $nginx_values ) |$key, $vhost| {
  nginx::resource::vhost { "${key}":
    vhost_cfg_prepend => {
      'root' => $vhost['docroot']
    },
    rewrite_www_to_non_www => true,
    proxy                  => 'http://127.0.0.1:7080',
    require => Class['apache'],
  }
}

create_resources('class', { 'nginx' => $nginx_settings })
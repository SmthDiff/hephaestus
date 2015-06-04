if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }

include ::apache::params

class { 'apache': }

$apache_version = '2.2'

$php_engine    = true
$php_fcgi_port = '9000'

$mpm_module = 'worker'

$sethandler_string = $php_engine ? {
  true    => "proxy:fcgi://127.0.0.1:${php_fcgi_port}",
  default => 'default-handler'
}

$www_root      = '/var/www'
$webroot_user  = 'www-data'
$webroot_group = 'www-data'

exec { 'Create apache webroot':
  command => "mkdir -p ${www_root} && \
              chown root:${webroot_group} ${www_root} && \
              chmod 775 ${www_root} && \
              touch /.hephaestus-config/apache-webroot-created",
  creates => '/.hephaestus-config/apache-webroot-created',
  require => [
    Group[$webroot_group],
    Class['apache']
  ],
}
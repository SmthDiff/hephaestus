if $apache_values == undef { $apache_values = hiera_hash('vhosts', false) }

include ::apache::params

$apache_version = '2.2'
$apache_modules = ['cgi', 'deflate', 'include', 'rewrite', 'userdir', 'autoindex', 'dir', 'headers', 'negotiation', 'setenvif', 'suexec', 'auth_basic', 'authz_default', 'fcgid', 'perl', 'python', 'authz_groupfile', 'reqtimeout', 'status', 'actions']

$mpm_module = 'worker'

$sethandler_string = "proxy:fcgi://127.0.0.1:9000"

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

$apache_settings = {
  'default_vhost'    => false,
  'mpm_module'       => $mpm_module,
  'conf_template'    => $::apache::params::conf_template,
  'apache_version'   => $apache_version,
  'server_root'      => $www_root,
  'server_tokens'    => 'Prod',
  'server_signature' => 'Off',
  'trace_enable'     => 'Off',
}

apache::listen { '7080': }

create_resources('class', { 'apache' => $apache_settings })

apache::fastcgi::server { 'php':
  host       => '127.0.0.1:9000',
  timeout    => 30,
  flush      => false,
  faux_path  => '/var/www/php.fcgi',
  fcgi_alias => '/php.fcgi',
  file_type  => 'application/x-httpd-php'
}

each( $apache_values ) |$key, $vhost| {
  exec { "exec mkdir -p ${vhost['docroot']} @ key ${key}":
    command => "mkdir -m 775 -p ${vhost['docroot']}",
    user    => $webroot_user,
    group   => $webroot_group,
    creates => $vhost['docroot'],
    require => Exec['Create apache webroot'],
  }

  apache::vhost { "${key}":
    port            => '7080',
    servername      => $vhost['servername'],
    docroot         => $vhost['docroot'],
    directories     => {
      path            => $vhost['docroot'],
      options         => ['Indexes', 'FollowSymlinks', 'MultiViews', 'Includes'],
      allow_override  => ['All'],
      require         => ['all granted'],
      files_match     => {'php_match' => {
        'provider'   => 'filesmatch',
        'path'       => '\.php$',
        'sethandler' => $sethandler_string,
      }},
      provider        => 'directory',
    },
    custom_fragment => 'AddType application/x-httpd-php .php',
    setenv          => $vhost['setenv'],
  }
}

each( $apache_modules ) |$module| {
  if ! defined(Apache::Mod[$module]) {
    apache::mod { $module: }
  }
}

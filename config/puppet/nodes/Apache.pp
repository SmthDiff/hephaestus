if $apache_values == undef { $apache_values = hiera_hash('vhosts', false) }

include hephaestus
include ::apache::params

$apache_version = '2.2'
$apache_modules = ['php5', 'cgi', 'deflate', 'include', 'rewrite', 'userdir', 'autoindex', 'dir', 'headers', 'negotiation', 'setenvif', 'suexec', 'auth_basic', 'authz_default', 'fcgid', 'perl', 'python', 'authz_groupfile', 'reqtimeout', 'status']

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
  'server_tokens'    => 'Prod',
  'server_signature' => 'Off',
  'trace_enable'     => 'Off',
}

apache::listen { '7080': }

create_resources('class', { 'apache' => $apache_settings })

each( $apache_values ) |$key, $vhost| {
  exec { "exec mkdir -p ${vhost['docroot']} @ key ${key}":
    command => "mkdir -m 775 -p ${vhost['docroot']}",
    user    => $webroot_user,
    group   => $webroot_group,
    creates => $vhost['docroot'],
    require => Exec['Create apache webroot'],
  }

  $default_vhost_directories = {"${key}" => {
    'path'            => "/var/www/${key}.dev",
    'options'         => ['Indexes', 'FollowSymlinks', 'MultiViews'],
    'allow_override'  => ['All'],
    'require'         => ['all granted'],
    'files_match'     => {'php_match' => {
      'path'       => '\.php$',
      'sethandler' => $sethandler_string,
      'provider'   => 'filesmatch',
    }},
    'provider'        => 'directory',
  }}

  $vhost_merged = merge($vhost, {
    'directories'     => values_no_error($default_vhost_directories),
    'port'            => '7080',
    'manage_docroot'  => false
  })

  create_resources(::apache::vhost, { "${key}" => $vhost_merged })

  $default_vhost_index_file =
    "${vhost['docroot']}/index.php"

  $default_vhost_source_file =
    '/vagrant/config/puppet/modules/hephaestus/files/webserver_landing.php'

  exec { 'Set index.html contents':
    command => "cat ${default_vhost_source_file} > ${default_vhost_index_file} && \
                chmod 644 ${default_vhost_index_file} && \
                chown ${webroot_user} ${default_vhost_index_file} && \
                chgrp ${webroot_group} ${default_vhost_index_file}",
    returns => [0, 1],
    require => Exec["exec mkdir -p ${vhost['docroot']} @ key ${key}"],
  }
}

each( $apache_modules ) |$module| {
  if ! defined(Apache::Mod[$module]) {
    apache::mod { $module: }
  }
}
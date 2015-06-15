if $apache_values == undef { $apache_values = hiera_hash('vhosts', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }

include ::apache::params

$apache_version = '2.2'
$apache_modules = ['php5', 'cgi', 'deflate', 'include', 'rewrite', 'userdir', 'autoindex', 'dir', 'headers', 'negotiation', 'setenvif', 'suexec', 'auth_basic', 'authz_default', 'fcgid', 'perl', 'python', 'authz_groupfile', 'reqtimeout', 'status']

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

$apache_settings = {
  'default_vhost'  => false,
  'mpm_module'     => $mpm_module,
  'conf_template'  => $::apache::params::conf_template,
  'apache_version' => $apache_version
}

apache::listen { '7080': }

create_resources('class', { 'apache' => $apache_settings })

$default_vhost_directories = {'default' => {
  'provider'        => 'directory',
  'path'            => '/var/www/',
  'options'         => ['Indexes', 'FollowSymlinks', 'MultiViews'],
  'allow_override'  => ['All'],
  'require'         => ['all granted'],
  'files_match'     => {'php_match' => {
    'provider'   => 'filesmatch',
    'path'       => '\.php$',
    'sethandler' => $sethandler_string,
  }},
  'custom_fragment' => '',
}}

each( $apache_values ) |$key, $vhost| {
  exec { "exec mkdir -p ${vhost['docroot']} @ key ${key}":
    command => "mkdir -m 775 -p ${vhost['docroot']}",
    user    => $webroot_user,
    group   => $webroot_group,
    creates => $vhost['docroot'],
    require => Exec['Create apache webroot'],
  }

  if array_true($vhost, 'directories') {
    $directories_hash   = $vhost['directories']
    $files_match        = template('hephaestus/apache/files_match.erb')
    $directories_merged = merge($vhost['directories'], hash_eval($files_match))
  } else {
    $directories_merged = []
  }

  $vhost_custom_fragment = array_true($vhost, 'custom_fragment') ? {
    true    => file($vhost['custom_fragment']),
    default => '',
  }

  notice("The value is: ${vhost}")

  $vhost_merged = merge($vhost, {
    'port'            => '7080',
    'custom_fragment' => $vhost_custom_fragment,
    'manage_docroot'  => false
  })

  notice("The value is: ${vhost_merged}")

  create_resources(::apache::vhost, { "${key}" => $vhost_merged })

  $default_vhost_index_file =
    "${vhost['docroot']}/index.html"

  exec { 'Set index.html contents':
    command => "echo 'welcome' > ${default_vhost_index_file} && \
                chmod 644 ${default_vhost_index_file} && \
                chown ${webroot_user} ${default_vhost_index_file} && \
                chgrp ${webroot_group} ${default_vhost_index_file}",
    returns => [0, 1],
    require => Exec['Create apache webroot'],
  }
}

each( $apache_modules ) |$module| {
  if ! defined(Apache::Mod[$module]) {
    apache::mod { $module: }
  }
}
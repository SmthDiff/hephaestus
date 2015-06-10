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

each( $apache_modules ) |$module| {
  if ! defined(Apache::Mod[$module]) {
    apache::mod { $module: }
  }
}
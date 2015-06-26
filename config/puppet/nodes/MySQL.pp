if $mysql_values == undef { $mysql_values = hiera_hash('vhosts', false) }

$mysql_settings = {
  root_password           => 'vagrant',
  remove_default_accounts => true,
  override_options        => $override_options
}

create_resources('class', { '::mysql::server' => $mysql_settings })

mysql_user{ 'vagrant@localhost':
  ensure        => 'present',
  password_hash => mysql_password('vagrant'),
}

mysql_grant { 'vagrant@localhost/*.*':
  ensure     => 'present',
  options    => ['GRANT'],
  privileges => ['ALL'],
  table      => '*.*',
  user       => 'vagrant@localhost',
}

each( $apache_values ) |$key, $vhost| {
  mysql::db { "${key}":
    user     => "${key}",
    password => 'vagrant',
    host     => 'localhost',
    grant    => ['ALL'],
  }
}
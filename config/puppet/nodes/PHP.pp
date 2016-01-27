if $php_values == undef { $php_values = hiera_hash('php', false) }

class { 'php':
	require => Class['apache'],
}

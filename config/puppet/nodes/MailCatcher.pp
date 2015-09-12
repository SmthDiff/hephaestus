class {'mailcatcher':
    smtp_ip => '0.0.0.0',
    http_ip => '0.0.0.0',
    service_enable => true
}
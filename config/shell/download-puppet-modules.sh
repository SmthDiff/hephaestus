#!/bin/bash

echo "Creating Puppet Modules Folder"
mkdir -p /etc/puppet/modules;
echo "Finished creating Puppet Modules Folder"

if [ ! -d /etc/puppet/modules/apt ]; then
	echo "Adding Apt Module"
	puppet module install puppetlabs-apt
	echo "Finished adding Apt Module"
fi

if [ ! -d /etc/puppet/modules/apache ]; then
	echo "Adding Apache Module"
	puppet module install puppetlabs-apache
	echo "Finished adding Apache Module"
fi

if [ ! -d /etc/puppet/modules/nginx ]; then
	echo "Adding Nginx Module"
	puppet module install puppet-nginx
	echo "Finished adding Nginx Module"
fi

if [ ! -d /etc/puppet/modules/php ]; then
	echo "Adding PHP Module"
	puppet module install puppet-php
	echo "Finished adding PHP Module"
fi

if [ ! -d /etc/puppet/modules/mysql ]; then
	echo "Adding MySQL Module"
	puppet module install puppetlabs-mysql
	echo "Finished adding MySQL Module"
fi

if [ ! -d /etc/puppet/modules/mailcatcher ]; then
	echo "Adding MailCatcher Module"
	puppet module install actionjack-mailcatcher
	echo "Finished adding MailCatcher Module"
fi

if [ ! -d /etc/puppet/modules/java ]; then
	echo "Adding Oracle Java Module"
	puppet module install 7terminals-java
	echo "Finished adding Oracle Java Module"
fi
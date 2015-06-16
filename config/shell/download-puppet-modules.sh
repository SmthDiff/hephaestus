#!/bin/bash

if [ ! -d /etc/puppet/modules ]; then
	echo "Creating Puppet Modules Folder"
	mkdir -p /etc/puppet/modules;
	echo "Finished creating Puppet Modules Folder"
fi

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
	puppet module install jfryman-nginx
	echo "Finished adding Nginx Module"
fi

if [ ! -d /etc/puppet/modules/php ]; then
	echo "Adding PHP Module"
	puppet module install mayflower-php
	echo "Finished adding PHP Module"
fi

if [ ! -d /etc/puppet/modules/mysql ]; then
	echo "Adding MySQL Module"
	puppet module install puppetlabs-mysql
	echo "Finished adding MySQL Module"
fi

if [ ! -d /etc/puppet/modules/nodejs ]; then
	echo "Adding NodeJS Module"
	puppet module install puppetlabs-nodejs
	echo "Finished adding NodeJS Module"
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

if [ ! -d /etc/puppet/modules/timezone ]; then
	echo "Adding timezone Module"
	puppet module install rlenglet-timezone
	echo "Finished adding timezone Module"
fi

if [ ! -d /etc/puppet/modules/ohmyzsh ]; then
	echo "Adding Oh-My-ZSH Module"
	puppet module install acme-ohmyzsh
	echo "Finished adding Oh-My-ZSH Module"
fi
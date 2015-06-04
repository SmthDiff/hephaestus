#!/bin/bash

echo "Creating Puppet Modules Folder"
mkdir -p /etc/puppet/modules;
echo "Finished creating Puppet Modules Folder"

if [ ! -d /etc/puppet/modules/apache ]; then
	echo "Adding Apache Module"
	puppet module install puppetlabs-apache
	echo "Finished adding Apache Module"
fi
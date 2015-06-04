#!/bin/bash

mkdir -p /etc/puppet/modules;

if [ ! -d /etc/puppet/modules/apache ]; then
	puppet module install puppetlabs-apache
fi
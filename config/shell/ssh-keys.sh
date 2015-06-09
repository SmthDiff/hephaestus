#!/bin/bash

VAGRANT_CORE_FOLDER=$(cat '/.hephaestus-config/vagrant-core-folder.txt')

if [[ -f /.hephaestus-config/added-ssh-keys ]]; then
    exit 0
fi

if [[ ! -f ${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa || ! -f ${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa.pub || ! -f ${VAGRANT_CORE_FOLDER}/files/ssh/config ]]; then
	echo 'Insufficient keys/config in config/files/ssh'
	echo 'Please add id_rsa, id_rsa.pub and config to config/files/ssh and reprovision'
	exit 0
fi

mkdir -p /root/.ssh
mkdir -p /home/vagrant/.ssh

cp "${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa" '/root/.ssh/'
cp "${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa.pub" '/root/.ssh/'
cp "${VAGRANT_CORE_FOLDER}/files/ssh/config" '/root/.ssh/'
cat "${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa.pub" >> '/root/.ssh/authorized_keys'

chown -R root '/root/.ssh'
chgrp -R root '/root/.ssh'
chmod 700 '/root/.ssh'
chmod 644 '/root/.ssh/id_rsa.pub'
chmod 600 '/root/.ssh/id_rsa'
chmod 600 '/root/.ssh/config'
chmod 600 '/root/.ssh/authorized_keys'

echo 'Added Root Keys'

cp "${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa" '/home/vagrant/.ssh/'
cp "${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa.pub" '/home/vagrant/.ssh/'
cp "${VAGRANT_CORE_FOLDER}/files/ssh/config" '/home/vagrant/.ssh/'
cat "${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa.pub" >> '/home/vagrant/.ssh/authorized_keys'

chown -R vagrant '/home/vagrant/.ssh'
chgrp -R vagrant '/home/vagrant/.ssh'
chmod 700 '/home/vagrant/.ssh'
chmod 644 '/home/vagrant/.ssh/id_rsa.pub'
chmod 600 '/home/vagrant/.ssh/id_rsa'
chmod 600 '/home/vagrant/.ssh/config'
chmod 600 '/home/vagrant/.ssh/authorized_keys'

echo 'Added Vagrant Keys'

touch /.hephaestus-config/added-ssh-keys
#!/bin/bash

VAGRANT_CORE_FOLDER=$(cat '/.hephaestus-config/vagrant-core-folder.txt')

mkdir -p /root/.ssh
mkdir -p /home/vagrant/.ssh

cp "${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa" '/root/.ssh/'
cp "${VAGRANT_CORE_FOLDER}/files/ssh/id_rsa.pub" '/root/.ssh/'
cp "${VAGRANT_CORE_FOLDER}/files/ssh/config" '/root/.ssh/'
cat "${VAGRANT_CORE_FOLDER}/files/ssh/authorized_keys" >> '/root/.ssh/authorized_keys'

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
cat "${VAGRANT_CORE_FOLDER}/files/ssh/authorized_keys" >> '/home/vagrant/.ssh/authorized_keys'

chown -R vagrant '/home/vagrant/.ssh'
chgrp -R vagrant '/home/vagrant/.ssh'
chmod 700 '/home/vagrant/.ssh'
chmod 644 '/home/vagrant/.ssh/id_rsa.pub'
chmod 600 '/home/vagrant/.ssh/id_rsa'
chmod 600 '/home/vagrant/.ssh/config'
chmod 600 '/home/vagrant/.ssh/authorized_keys'

echo 'Added Vagrant Keys'
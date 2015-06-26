require 'yaml'

# Reading YAML Confiuration File for changing specs
dir = File.dirname(File.expand_path(__FILE__))
configValues = YAML.load_file("#{dir}/config/config.yaml")

Vagrant.configure('2') do |config|
  # Defining which box shall be downloaded
  config.vm.box     = "ubuntu/precise64"
  config.vm.box_url = "ubuntu/precise64"
  config.vm.hostname = "hephaestus"
  config.vm.network 'private_network', ip: "192.168.33.101"

  # defining default provider as VirtualBox
  ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

  # defining standard VM config for VirtualBox
  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.customize ['modifyvm', :id, '--name', config.vm.hostname]
    virtualbox.customize ['modifyvm', :id, '--memory', '1024']
    virtualbox.customize ['modifyvm', :id, '--cpus', '1']
    virtualbox.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
  end

  # defining folders to sync between host and guest
  configValues['synced_folder'].each do |i, folder|
    sync_owner = "#{folder['owner']}"
    sync_group = "#{folder['group']}"
    config.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}",
      group: sync_group, owner: sync_owner, mount_options: ['dmode=775', 'fmode=774']
  end

  # adding vhosts to hosts file with vagrant hostmanager
  # must install with 'vagrant plugin install vagrant-hostmanager'
  if Vagrant.has_plugin?('vagrant-hostmanager')
    hosts = Array.new()

    configValues['vhosts'].each do |i, vhost|
      hosts.push(vhost['servername'])
    end
    
    if hosts.any?
      config.hostmanager.enabled           = true
      config.hostmanager.manage_host       = true
      config.hostmanager.ignore_private_ip = false
      config.hostmanager.include_offline   = false
      config.hostmanager.aliases           = hosts
    end
  end

  # updating virtualbox guest additions
  # must install with 'vagrant plugin install vagrant-vbguest'
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = true
    config.vbguest.auto_reboot = true
    config.vbguest.no_remote = true
  end

  # initial shell provisioning (updates, upgrades)
  config.vm.provision 'shell' do |s|
    s.path = 'config/shell/initial-setup.sh'
    s.args = '/vagrant/config'
  end

  # adding SmthDiff SSH Keys to box
  config.vm.provision :shell, :path => 'config/shell/ssh-keys.sh'

  # install ruby
  config.vm.provision :shell, :path => 'config/shell/install-ruby.sh'

  # install puppet 3.4.3
  config.vm.provision :shell, :path => 'config/shell/install-puppet.sh'

  # download needed puppet modules
  config.vm.provision :shell, :path => 'config/shell/download-puppet-modules.sh'

  # provisioning everything else with puppet
  config.vm.provision :puppet do |puppet|
    puppet.facter = {
      'fqdn'             => "#{config.vm.hostname}",
      'ssh_username'     => 'vagrant',
      'provisioner_type' => ENV['VAGRANT_DEFAULT_PROVIDER'],
    }
    puppet.manifests_path = 'config/puppet'
    puppet.manifest_file = 'default.pp'
    puppet.module_path = 'config/puppet/modules'
    puppet.options = '--hiera_config /vagrant/config/puppet/hiera.yaml --parser future'
  end

end
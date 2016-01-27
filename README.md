# Vagrant Box Hephaestus
### For PHP Development

#### Requires:
* Vagrant 1.6+
* VirtualBox
* vagrant plugin install vagrant-hostmanager
* vagrant plugin install vagrant-vbguest

#### Uses:
* Vagrant
* Puppet
* Ubuntu 12.04 LTS
* Apache Backend
* Nginx Frontend
* PHP-FPM
* MySQL
* Mailcatcher
* NodeJS/NPM (Gulp, Bower, Grunt, Foundation, JSPM, eslint, Parallelshell, mkdirp, npm-build-tools)
* RubyGems (Compass)

#### config.yaml
* rename config/config.yaml.default to config/config.yaml
* add hosts in config/config.yaml
* add npm/gems/debs
* change where your code is saved (standard: ~/Code)

#### Add your personal SSH keys
* add id_rsa, id_rsa.pub and config (Key forwarding) to config/files/ssh

#### Change your dotfiles
* Change your username and email in config/files/dot/.gitconfig
* Add standard gitignores in config/files/dot/.gitignore_global
* Change Oh-My-ZSH configuration in config/files/dot/.zshrc
* Change NPM configuration in config/files/dot/.npmrc

### Have fun!

### SmthDiff Designs

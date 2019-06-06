# -*- mode: ruby -*-
# vi: set ft=ruby :

# detect operating system
require "./scripts/osdetection.rb"

# create local domain name e.g devops-riaan.example
user = ENV["USER"].downcase
fqdn = ENV["fqdn"] || "devops-#{user}"

# https://www.virtualbox.org/manual/ch08.html
vbox_config = [
  { '--memory' => '2048' },
  { '--cpus' => '2' },
  { '--cpuexecutioncap' => '100' },
  { '--biosapic' => 'x2apic' },
  { '--ioapic' => 'on' },
  { '--largepages' => 'on' },
  { '--natdnshostresolver1' => 'on' },
  { '--natdnsproxy1' => 'on' },
  { '--nictype1' => 'virtio' },
]

# machine(s) hash
machines = [
  {
    :name => "#{fqdn}",
    :ip => '10.9.99.10',
    :ssh_port => '2255',
    :disksize => '10GB',
    :vbox_config => vbox_config,
    :synced_folders => [
      { :vm_path => '/var/www', :ext_rel_path => '.', :vm_owner => 'www-data' }
    ],
  }
]

Vagrant::configure("2") do |config|

  # check for vagrant version
  Vagrant.require_version ">= 1.9.7"

  # use scripts/osdetection.rb to determine OS
  COMMAND_SEPARATOR = OS.windows? ? "&" : ";"

  # auto install plugins, will prompt for admin password on 1st vagrant up
  required_plugins = %w( vagrant-hostsupdater vagrant-disksize )
  required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin}#{COMMAND_SEPARATOR}vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
  end

  machines.each do |machine|

    config.vm.box = "ubuntu/xenial64"
    config.vm.define machine[:name] do |host|

      config.disksize.size = machine[:disksize]
      config.ssh.forward_agent = true
      config.ssh.insert_key = true
      config.vm.network "private_network", ip: machine[:ip]
      config.vm.network "forwarded_port", guest: 22, host: machine[:ssh_port], id: 'ssh', auto_correct: true
      config.hostsupdater.aliases = [ "#{fqdn}.example", "www.example", "mysql.example", "elasticsearch.example", "redis.example", "memcache.example", "beanstalk.example"]
      config.vm.hostname = machine[:name]+".example"

      unless machine[:vbox_config].nil?
        config.vm.provider :virtualbox do |vb|
          machine[:vbox_config].each do |hash|
            hash.each do |key, value|
              vb.customize ['modifyvm', :id, "#{key}", "#{value}"]
            end
          end
        end
      end

      # mount the shared folder inside the VM
      unless machine[:synced_folders].nil?
        machine[:synced_folders].each do |folder|
          config.vm.synced_folder "#{folder[:ext_rel_path]}", "#{folder[:vm_path]}", owner: "#{folder[:vm_owner]}", mount_options: ["dmode=775,fmode=775"]
          # below will mount shared folder via NFS
          # config.vm.synced_folder "#{folder[:ext_rel_path]}", "#{folder[:vm_path]}", nfs: true, nfs_udp: false, mount_options: ['nolock', 'noatime', 'lookupcache=none', 'async'], linux__nfs_options: ['rw','no_subtree_check','all_squash','async']
        end
      end

      # vagrant up $fqdn --provision-with bootstrap to only run this on vagrant up
      config.vm.provision "bootstrap", type: "shell", privileged: false, inline: <<-SHELL
        echo BEGIN BOOTSTRAP $(date '+%Y-%m-%d %H:%M:%S')
        echo running vagrant as #{user}
        # install applications
        sudo apt-get --assume-yes update
        sudo apt-get --assume-yes upgrade
        sudo apt-get --assume-yes autoremove
        sudo apt-get --assume-yes install apache2 software-properties-common python-openssl

        # if the user IS jenkins, the we are running this from a Jenkinsfile (Scripted Pipelines)
        if [ "#{user}" != "jenkins" ]; then
          cd "#{machine[:synced_folders][0][:vm_path]}"
          printenv
          # below is run from the Makefile, shorthand commands to run composer, gulp, database importer
          # make bootstrap
        fi
        echo END BOOTSTRAP $(date '+%Y-%m-%d %H:%M:%S')
      SHELL

      # for puppet this will run scripts/puppet.sh (install puppet agent, knock to gain access, run puppet agent)
      # config.vm.provision "puppet", type: "shell", path: "scripts/puppet.sh"

      # for ansible
      # config.vm.provision "ansible_local" do |ansible|
      #   ansible.verbose = "v"
      #   ansible.install_mode = "pip"
      #   ansible.version = "2.4.2.0"
      #   ansible.compatibility_mode = "2.0"
      #   ansible.galaxy_role_file = "/home/vagrant/ansible-playbooks/base/requirements.yml"
      #   ansible.galaxy_roles_path = "/etc/ansible/roles"
      #   ansible.galaxy_command = "sudo ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path}" # --force add later
      #   ansible.limit = "base"
      #   ansible.inventory_path = "/home/vagrant/ansible-playbooks/inventory-local"
      #   ansible.playbook = "/home/vagrant/ansible-playbooks/base/site.yml"
      #   ansible.become = true
      #   vagrant_synced_folder_default_type = ""
      # end

    end
  end
end

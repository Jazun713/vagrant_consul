require 'chef'
require 'chef/config'
require 'chef/knife'
# current_dir = File.dirname(__FILE__)
Chef::Config.from_file(File.expand_path('./.chef/knife.rb'))

nodes = {
  :consul_1 => {
    :hostname => 'consul-1',
    :ipaddress => '10.0.1.2',
    :bootstrapip => '10.0.1.2',
    :run_list => [ 'role[consul-platform]' ],
    :forwardport => {
      :guest => 8301,
      :host => 8301
    }
  },
  :consul_2 => {
    :hostname => 'consul-2',
    :ipaddress => '10.0.1.3',
    :bootstrapip => '10.0.1.2',
    :run_list => [ 'role[consul-platform]' ],
    :forwardport => {
      :guest => 8301,
      :host => 8401
    }
  },
  :consul_3 => {
    :hostname => 'consul-3',
    :ipaddress => '10.0.1.4',
    :bootstrapip => '10.0.1.2',
    :run_list => [ 'role[consul-platform]' ],
    :forwardport => {
      :guest => 8301,
      :host => 8501
    }
  }
}

Vagrant.configure('2') do |config|
  nodes.each do |node, options|
    config.vm.define node do |node_config|
      node_config.ohai.primary_nic = 'enp0s8'
      node_config.vm.box = 'bento/ubuntu-16.04'
      node_config.vm.hostname = options[:hostname]
      node_config.vm.network 'private_network', ip: options[:ipaddress]
      bootstrapip = options[:bootstrapip]
      node_config.vm.provision 'shell', inline: "echo #{bootstrapip} consul-1 >> /etc/hosts"
      node_config.omnibus.chef_version = "12.19.36"
      if options.key?(:forwardport)
        node_config.vm.network :forwarded_port, guest: options[:forwardport][:guest], host: options[:forwardport][:host]
      end
      node_config.vm.provision :chef_client do |chef|
        chef.chef_server_url = Chef::Config[:chef_server_url]
        chef.validation_key_path = Chef::Config[:validation_key]
        chef.validation_client_name = Chef::Config[:validation_client_name]
        chef.node_name = options[:hostname]
        chef.run_list = options[:run_list]
        chef.provisioning_path = '/etc/chef'
        chef.log_level = :info
      end
    end
  end
end

cookbook_name = 'consul-platform'

# Cluster configuration with cluster-search
# Role used by the search to find other nodes of the cluster
override[cookbook_name]['role'] = cookbook_name
# Hosts of the cluster, deactivate search if not empty
override[cookbook_name]['hosts'] = []
# Expected size of the cluster. Ignored if hosts is not empty
override[cookbook_name]['size'] = 1

# Id of the node that will first initiate/create the cluster.
# This id is provided by cluster-search
override[cookbook_name]['initiator_id'] = 1

# consul version
override[cookbook_name]['version'] = '0.7.2'
version = node[cookbook_name]['version']
# package sha256 checksum
override[cookbook_name]['checksum'] =
  'aa97f4e5a552d986b2a36d48fdc3a4a909463e7de5f726f3c5a89b8a1be74a58'

# Where to get the zip file
binary = "consul_#{version}_linux_amd64.zip"
override[cookbook_name]['mirror'] =
  "https://releases.hashicorp.com/consul/#{version}/#{binary}"

# User and group of consul process
override[cookbook_name]['user'] = 'consul'
override[cookbook_name]['group'] = 'consul'

# Where to put installation dir
override[cookbook_name]['prefix_root'] = '/opt'
# Where to link installation dir
override[cookbook_name]['prefix_home'] = '/opt'
# Where to link binaries
override[cookbook_name]['prefix_bin'] = '/opt/bin'

# Data directory
override[cookbook_name]['data_dir'] =
  "#{node[cookbook_name]['prefix_home']}/consul/data"

# Configuration directory
override[cookbook_name]['config_dir'] =
  "#{node[cookbook_name]['prefix_home']}/consul/consul.d"

# Consul configuration
override[cookbook_name]['config'] = {
  'bootstrap.json' => {
    'bootstrap' => false,
    'server' => true,
    'datacenter' => 'slc1',
    'data_dir' => '/opt/consul/data',
    'log_level' => 'INFO',
    'enable_syslog' => true
  }
}

# Consul daemon options
override[cookbook_name]['options'] = {
  'advertise' => node['ipaddress'],
  'config-dir' => node[cookbook_name]['config_dir']
}

# Systemd service unit, include config
override[cookbook_name]['systemd_unit'] = {
  'Unit' => {
    'Description' => 'consul agent',
    'After' => 'network.target'
  },
  'Service' => {
    'User' => node[cookbook_name]['user'],
    'Group' => node[cookbook_name]['group'],
    'Environment' => 'GOMAXPROCS=2',
    'ExecStart' => 'TO_BE_COMPLETED',
    'ExecReload' => '/bin/kill -9 $MAINPID',
    'Restart' => 'on-failure',
    'RestartSec' => '1'
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Configure retries for the package resources, default = global default (0)
# (mostly used for test purpose)
override[cookbook_name]['package_retries'] = nil

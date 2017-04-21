#
# Copyright (c) 2016-2017 Sam4Mobile
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

cookbook_name = 'consul-platform'

# Create consul data && config directories

%w(data_dir config_dir).each do |dir|
  directory node[cookbook_name][dir] do
    user node[cookbook_name]['user']
    group node[cookbook_name]['user']
    mode '0755'
  end
end

# Deploy consul configuration (services, health checks)
if node[cookbook_name]['config']
  node[cookbook_name]['config'].each do |file, config|
    file "#{node[cookbook_name]['config_dir']}/#{file}" do
      content config.to_json
      owner node[cookbook_name]['user']
      group node[cookbook_name]['group']
      mode '0640'
    end
  end
end

# Modifications for allowing template transform
template 'consul_service_config' do
  path "#{node[cookbook_name]['config_dir']}/config.json"
  source 'config.erb'
  owner node[cookbook_name]['user']
  group node[cookbook_name]['user']
  mode '0640'
end

# Generate options hash from attribute
options = node[cookbook_name]['options'].to_hash
# Set custom options parameters if node is the initiator
if node.run_state[cookbook_name]['iam_initiator']
  options['bootstrap'] = ''
else
  # Node have to join the cluster
  options['join'] = node.run_state[cookbook_name]['initiator']
end

# Store options to reuse them later
node.run_state[cookbook_name]['options'] = options

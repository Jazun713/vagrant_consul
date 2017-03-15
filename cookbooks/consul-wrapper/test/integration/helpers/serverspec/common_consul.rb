# Copyright (c) 2015-2017 Sam4Mobile
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

require 'spec_helper'

describe 'Consul' do
  it 'Server RPC is listening on correct port' do
    expect(port(8300)).to be_listening
  end
  it 'Serf LAN is listening on correct port' do
    expect(port(8301)).to be_listening
  end
  it 'Serf WAN is listening on correct port' do
    expect(port(8302)).to be_listening
  end
  it 'Cli RPC is listening on correct port' do
    expect(port(8400)).to be_listening
  end
  it 'HTTP API is listening on correct port' do
    expect(port(8500)).to be_listening
  end
  it 'DNS Interface is listening on correct port' do
    expect(port(8600)).to be_listening
  end
end

cmd = '/opt/consul/consul members'
node_name = host_inventory['hostname']

describe 'Cluster members status' do
  describe command(cmd) do
    its(:stdout) { should contain(node_name) }
  end
end

hosts = [
  'consul-platform-1-centos-7',
  'consul-platform-2-centos-7',
  'consul-platform-3-centos-7'
]

def read(key)
  `/opt/consul/consul kv get #{key}`
end

def write(key, value)
  `/opt/consul/consul kv put #{key} #{value}`
end

def wait_server_availability(server)
  (1..20).each do |try|
    cmd = '/opt/consul/consul members'
    result = `#{cmd} 2>&1`
    break if result.include?(server)
    puts "Waiting for #{server} availability . Try ##{try}/20, waiting 5s"
    sleep(5)
  end
end

def wait_replication(kv)
  (1..20).each do |try|
    break if read(kv).include?(kv)
    puts "Waiting for key replication on #{server}. Try ##{try}/20, waiting 5s"
    sleep(5)
  end
end

describe 'Replication' do
  # Write key on the local server
  write(node_name, node_name)
  hosts.each do |server|
    it "#{node_name} should have #{server} key created" do
      wait_server_availability(server)
      # Check if other keys have been replicated on local server
      wait_replication(server)
      expect(read(server)).to include(server)
    end
  end
end

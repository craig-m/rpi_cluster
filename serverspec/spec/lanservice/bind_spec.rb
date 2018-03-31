require 'spec_helper'
# bind dns

describe package('bind9') do
  it { should be_installed }
end

describe service('bind9') do
  it { should be_enabled }
  it { should be_running }
end

describe host('localhost') do
  it { should be_reachable.with( :port => 953 ) }
end

describe port(53) do
  it { should be_listening.with('tcp') }
end

describe user('bind') do
  it { should exist }
  it { should have_login_shell '/bin/false' }
end

describe file('/etc/bind/named.conf.options') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end

describe file('/etc/bind/named.conf.local') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
 its(:content) { should contain "type #{property[:rpi_dnsd_status]};" }
end

describe file('/etc/bind/named.conf.default-zones') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end

describe file("/etc/bind/zones/#{property[:rpi_dnsd_status]}/") do
  it { should be_directory }
  it { should be_owned_by 'bind' }
end

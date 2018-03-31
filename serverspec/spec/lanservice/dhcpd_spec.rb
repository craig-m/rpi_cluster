require 'spec_helper'
# dhcpd SERVER

describe package('isc-dhcp-server') do
  it { should be_installed }
end

describe service('isc-dhcp-server') do
  it { should be_enabled }
  it { should be_running }
end

describe port(647) do
  it { should be_listening.with('tcp') }
end

describe file('/etc/dhcp/dhcpd.conf') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
 it { should contain "#{property[:server_status_dhcp]};" }
end

describe command('/usr/lib/nagios/plugins/check_dhcp') do
  its(:exit_status) { should eq 0 }
end

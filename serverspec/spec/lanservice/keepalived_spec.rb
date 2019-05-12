require 'spec_helper'


describe package('keepalived') do
  it { should be_installed }
end


describe service('keepalived.service') do
  it { should be_enabled }
  it { should be_running }
  it { should be_running.under('systemd') }
end


describe file('/etc/keepalived/keepalived.conf') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end


describe process("keepalived") do
  its(:user) { should eq "root" }
end

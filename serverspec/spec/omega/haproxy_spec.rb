require 'spec_helper'

describe service('haproxy.service') do
  it { should be_enabled }
  it { should be_running }
  it { should be_running.under('systemd') }
end

describe user('haproxy') do
  it { should exist }
end

describe file('/etc/haproxy/haproxy.cfg') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end

describe host("localhost") do
  it { should be_reachable.with( :port => 80, :proto => 'tcp' ) }
end

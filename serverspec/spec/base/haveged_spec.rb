require 'spec_helper'

describe package('haveged') do
  it { should be_installed }
end

describe service('haveged') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/default/haveged') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /DAEMON_ARGS="-w 1024"/ }
end

describe file('/opt/cluster/data/info_roles.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /haveged/ }
end

describe process("haveged") do
  its(:user) { should eq "root" }
  its(:count) { should eq 1 }
end

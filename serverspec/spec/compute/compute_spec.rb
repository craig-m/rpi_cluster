require 'spec_helper'

describe file('/opt/cluster/bin/compute-boot.sh') do
 it { should be_file }
 it { should be_owned_by 'root' }
 it { should be_grouped_into 'root' }
 its(:content) { should match /compute-boot.sh/ }
 it { should be_mode 770 }
end

describe file('/opt/cluster/data/info_roles.txt') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode 444 }
 its(:content) { should match /group-compute/ }
end

describe file('/mnt/ramstore/data/test.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
end

describe file('/etc/ssh/sshd_config') do
 its(:content) { should match /AuthorizedKeysFile \/dev\/null/ }
 its(:content) { should match /TrustedUserCAKeys \/etc\/ssh\/ca.pub/ }
end

describe package('openjdk-8-jdk') do
  it { should be_installed }
end

# these users should be added
describe user('computeadm') do
  it { should exist }
end

# these users should NOT exist here
describe user('omegapyapi') do
  it { should_not exist }
end
describe user('bbweb') do
  it { should_not exist }
end
describe user('bind') do
  it { should_not exist }
end
describe user('redis') do
  it { should_not exist }
end
describe user('tftp') do
  it { should_not exist }
end

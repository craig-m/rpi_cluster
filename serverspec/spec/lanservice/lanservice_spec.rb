require 'spec_helper'

describe file('/opt/cluster/data/info_roles.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
 it { should be_mode 444 }
 its(:content) { should match /group-lanservices/ }
end

describe service('rpi-lanservices.service') do
  it { should be_enabled }
end

describe file('/etc/ssh/sshd_config') do
 its(:content) { should match /AuthorizedKeysFile \/dev\/null/ }
 its(:content) { should match /TrustedUserCAKeys \/etc\/ssh\/ca.pub/ }
end

# no docker on these older slow r-pi
describe file('/usr/bin/docker') do
  it { should_not exist }
end

describe file('/home/mpiuser/') do
  it { should_not exist }
end

describe file('/root/bin/lanservices-boot.sh') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
 it { should be_mode 770 }
end

describe file('/mnt/ramstore/data/hour_check.txt') do
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe file('/mnt/ramstore/data/test.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
end

# lanservices cron
describe cron do
  it { should have_entry('@daily /root/crontab/lansrvmain-cron-daily.sh').with_user('root') }
end

# should not exist here
describe user('mpiuser') do
  it { should_not exist }
end
describe user('redis') do
  it { should_not exist }
end
describe user('computeadm') do
  it { should_not exist }
end
describe user('puppet') do
  it { should_not exist }
end

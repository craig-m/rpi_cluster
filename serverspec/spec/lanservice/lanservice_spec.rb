require 'spec_helper'

describe file('/opt/cluster/data/info_roles.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /group-lanservices/ }
 it { should be_mode 444 }
end

describe service('rpi-lanservices.service') do
  it { should be_enabled }
end

# no docker on these older slow r-pi
describe file('/usr/bin/docker') do
  it { should_not exist }
end

describe file('/home/mpiuser/') do
  it { should_not exist }
end

describe file('/opt/cluster/bin/lanservices-boot.sh') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
 it { should be_mode 770 }
end

describe file('/mnt/ramstore/data/test.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
end

# lanservices cron
describe cron do
  it { should have_entry('30 01 * * 7 /root/crontab/lansrvmain-cron-daily').with_user('root') }
end

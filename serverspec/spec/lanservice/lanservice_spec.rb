require 'spec_helper'


describe file('/opt/cluster/data/info_roles.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /lanservices-node/ }
 it { should be_mode 444 }
end


describe service('rpi-lanservices.service') do
  it { should be_enabled }
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
  it { should have_entry('@hourly bash -c /opt/cluster/bin/lansrv-cron-hourly.sh > 2>&1').with_user('root') }
  it { should have_entry('@daily bash -c /opt/cluster/bin/lansrv-cron-daily.sh > 2>&1').with_user('root') }
end

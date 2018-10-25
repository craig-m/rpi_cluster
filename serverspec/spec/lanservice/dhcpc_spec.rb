require 'spec_helper'
# dhcpc CLIENT

describe file('/etc/dhcpcd.conf') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end

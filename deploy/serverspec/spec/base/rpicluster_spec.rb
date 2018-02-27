require 'spec_helper'
# R-Pi Cluster common


describe file('/opt/cluster/data/info_host.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /Raspberry Pi Cluster/ }
 it { should be_mode 444 }
end

describe file('/opt/cluster/data/info_roles.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /Ansible Roles run against this host/ }
 it { should be_mode 444 }
end



describe file('/home/pi/tmp') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/root/bin') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/root/tmp') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

# /opt/cluster
describe file('/opt/cluster/data') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/opt/cluster/mysrc') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

# /mnt
describe file('/mnt/usbkey') do
  it { should be_directory }
end

describe file('/mnt/sshfs') do
  it { should be_directory }
end

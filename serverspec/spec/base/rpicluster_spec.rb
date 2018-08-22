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

describe user('piclust') do
  it { should exist }
end

describe file('/var/log/rpicluster.log') do
  it { should be_file }
  it { should be_grouped_into 'adm' }
end

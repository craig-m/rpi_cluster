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

describe file('/opt/cluster/bin/compute-boot.sh') do
 it { should be_file }
 it { should be_owned_by 'root' }
 it { should be_mode 770 }
end

describe package('openjdk-8-jdk') do
  it { should be_installed }
end


describe user('computeadm') do
  it { should exist }
end

# should not exist here
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

require 'spec_helper'


describe file('/opt/cluster/data/info_roles.txt') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode 444 }
  its(:content) { should match /group-deployer-ssh-client/ }
  its(:content) { should match /group-deployer/ }
  its(:content) { should match /redis/ }
end


describe process("gpg-agent") do
  its(:count) { should eq 1 }
  its(:user) { should eq "pi" }
end

describe process("ssh-agent") do
  its(:user) { should eq "pi" }
end


describe file('/etc/ssh/sshd_config') do
  its(:content) { should match /AuthorizedKeysFile \/home\/pi\/.ssh\/authorized_keys/ }
end


describe service('rpi-deployer.service') do
  it { should be_enabled }
end

describe file('/mnt/ramstore/data/test.txt') do
  it { should be_file }
  it { should be_owned_by 'root' }
end


# services shoult NOT be listening here
describe port(5353) do
  it { should_not be_listening }
end
describe port(443) do
  it { should_not be_listening }
end
describe port(80) do
  it { should_not be_listening }
end


# should not exist here
describe user('mpiuser') do
  it { should_not exist }
end
describe user('bind') do
  it { should_not exist }
end
describe user('omegapyapi') do
  it { should_not exist }
end
describe user('tftp') do
  it { should_not exist }
end
describe user('computeadm') do
  it { should_not exist }
end
describe user('puppet') do
  it { should_not exist }
end

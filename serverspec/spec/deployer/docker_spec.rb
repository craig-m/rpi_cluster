require 'spec_helper'

describe service('docker.service') do
  it { should be_enabled }
  it { should be_running }
end

describe group('docker') do
  it { should exist }
end

describe file('/opt/cluster/docker/docker-installed.txt') do
  it { should be_file }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe process("dockerd") do
  its(:user) { should eq "root" }
end

describe command('docker ps') do
  its(:exit_status) { should eq 0 }
end
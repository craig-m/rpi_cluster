require 'spec_helper'

describe service('docker.service') do
  it { should be_enabled }
  it { should be_running }
end

describe group('docker') do
  it { should exist }
end

describe process("dockerd") do
  its(:user) { should eq "root" }
end

describe command('docker ps') do
  its(:exit_status) { should eq 0 }
end
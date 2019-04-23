require 'spec_helper'

describe package('openssh-server') do
  it { should be_installed }
end

describe package('openssh-client') do
  it { should be_installed }
end

describe service('ssh') do
  it { should be_enabled }
  it { should be_running }
end

describe process("/usr/sbin/sshd") do
  its(:count) { should eq 1 }
end

describe process("sshd") do
  its(:user) { should eq "root" }
end

describe user('sshd') do
  it { should exist }
end

describe file('/etc/ssh/sshd_config') do
  its(:content) { should match /R-Pi Cluster Ansible managed file/ }
  its(:content) { should match /PermitRootLogin No/ }
  its(:content) { should match /PasswordAuthentication no/ }
  its(:content) { should match /AllowGroups sshusers/ }
  it { should be_mode 600 }
end

describe file('/etc/motd') do
  its(:content) { should match /Raspberry Pi Cluster/ }
  it { should be_mode 644 }
end

describe host('127.0.0.1') do
  it { should be_reachable.with( :port => 22 ) }
end

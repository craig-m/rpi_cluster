require 'spec_helper'

describe service('tftpd-hpa.service') do
  it { should be_enabled }
  it { should be_running }
  it { should be_running.under('systemd') }
end

describe file('/etc/default/tftpd-hpa') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end

describe user('tftp') do
  it { should exist }
  it { should have_login_shell '/bin/false' }
end

describe file('/srv/tftp/pxelinux/') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_mode 755 }
end

describe file('/srv/tftp/dl/') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_mode 755 }
end

describe process("in.tftpd") do
  its(:user) { should eq "root" }
  its(:count) { should eq 1 }
end

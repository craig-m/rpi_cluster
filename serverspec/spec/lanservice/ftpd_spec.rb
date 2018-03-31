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

describe file('/srv/tftp/') do
  it { should be_directory }
  it { should be_owned_by 'root' }
end

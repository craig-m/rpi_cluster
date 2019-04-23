require 'spec_helper'

describe file('/opt/cluster/data/info_roles.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
 it { should be_mode 444 }
 its(:content) { should match /host-omega/ }
end

describe file('/etc/ssh/sshd_config') do
 its(:content) { should match /AuthorizedKeysFile \/dev\/null/ }
 its(:content) { should match /TrustedUserCAKeys \/etc\/ssh\/ca.pub/ }
end

describe command('/usr/bin/curl -X GET --unix-socket /opt/omegapyapi/omegapyapi.socket http/hello/curltest') do
  let(:disable_sudo) { true }
  its(:stdout) { should match 'Hello curltest' }
end

describe user('omegapyapi') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
end

# services shoult NOT be listening here
describe port(53) do
  it { should_not be_listening }
end
describe port(5353) do
  it { should_not be_listening }
end

# should NOT exist here
describe user('bbweb') do
  it { should_not exist }
end
describe user('bind') do
  it { should_not exist }
end
describe user('tftp') do
  it { should_not exist }
end
describe user('computeadm') do
  it { should_not exist }
end

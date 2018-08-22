require 'spec_helper'

# time and date
describe command('timedatectl status') do
  its(:stdout) { should contain('Time zone: UTC') }
  its(:stdout) { should contain('NTP synchronized: yes') }
end

describe package('ntp') do
  it { should be_installed }
end

describe service('ntp') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/ntp.conf') do
 it { should be_file }
 it { should be_owned_by 'root' }
end

describe process("ntpd") do
  its(:user) { should eq "ntp" }
end

describe user('ntp') do
  it { should exist }
  it { should have_login_shell '/bin/false' }
end

describe host('au.pool.ntp.org') do
  it { should be_resolvable }
end

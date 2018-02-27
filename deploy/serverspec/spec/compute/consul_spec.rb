require 'spec_helper'


describe file('/opt/consul/') do
  it { should be_directory }
end


describe file('/opt/consul/consul.d/') do
  it { should be_directory }
end


describe file('/etc/systemd/system/consul.service') do
  it { should be_writable.by('owner') }
  it { should be_readable.by('group') }
  it { should be_readable.by('others') }
end


describe service('consul.service') do
  it { should be_enabled }
  it { should be_running }
  it { should be_running.under('systemd') }
end


describe file('/usr/local/sbin/consul') do
  it { should be_executable.by('owner') }
  it { should be_executable.by('group') }
  it { should be_executable.by('others') }
  it { should be_executable.by_user('consul') }
end


describe 'consul Port open' do
  describe port(8500) do
    it { should be_listening }
    it { should be_listening.with('tcp') }
  end
end

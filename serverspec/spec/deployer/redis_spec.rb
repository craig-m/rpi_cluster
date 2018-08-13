require 'spec_helper'

describe service('redis-server.service') do
  it { should be_running }
  it { should be_running.under('systemd') }
end

describe 'redis Port open' do
  describe port(6379) do
    it { should be_listening }
    it { should be_listening.with('tcp') }
  end
end

describe user('redis') do
  it { should exist }
  it { should have_login_shell '/bin/false' }
end

describe process("/usr/bin/redis-server") do
  its(:count) { should eq 1 }
end

describe command('/usr/bin/redis-cli -h localhost -p 6379 ping') do
  let(:disable_sudo) { true }
  its(:stdout) { should match 'PONG' }
end

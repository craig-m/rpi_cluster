require 'spec_helper'
# bind dns

describe package('bind9') do
  it { should be_installed }
end

describe service('bind9') do
  it { should be_enabled }
  it { should be_running }
end

describe process("named") do
  its(:user) { should eq "bind" }
  its(:count) { should eq 1 }
end

describe host('localhost') do
  it { should be_reachable.with( :port => 953 ) }
end

describe port(53) do
  it { should be_listening.with('tcp') }
end

describe user('bind') do
  it { should exist }
  it { should have_login_shell '/usr/sbin/nologin' }
end

describe file('/etc/bind/named.conf.options') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end

describe file('/etc/bind/named.conf.local') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
 its(:content) { should contain "type: #{property[:rpi_dnsd_status]}" }
end

describe file('/etc/bind/named.conf.default-zones') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end

describe file("/etc/bind/zones/#{property[:rpi_dnsd_status]}/") do
  it { should be_directory }
  it { should be_owned_by 'bind' }
end

describe command('/usr/sbin/named-checkconf /etc/bind/named.conf') do
  its(:stdout) { should match // }
end

describe command("dig @localhost www.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]} | grep 'www.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}.'") do
  its(:exit_status) { should eq 0 }
  let(:disable_sudo) { true }
end

describe command("dig @127.0.0.1 -t TXT txttest.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}  | grep -A1 ';; ANSWER SECTION:'") do
  its(:stdout) { should contain('txttest rpi_cluster_test').after('ANSWER SECTION') }
  let(:disable_sudo) { true }
end

describe command("dig @alpha -t TXT txttest.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}  | grep -A1 ';; ANSWER SECTION:'") do
  its(:stdout) { should contain('txttest rpi_cluster_test').after('ANSWER SECTION') }
  let(:disable_sudo) { true }
end

describe command("dig @beta -t TXT txttest.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}  | grep -A1 ';; ANSWER SECTION:'") do
  its(:stdout) { should contain('txttest rpi_cluster_test').after('ANSWER SECTION') }
  let(:disable_sudo) { true }
end

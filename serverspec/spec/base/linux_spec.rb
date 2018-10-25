require 'spec_helper'
# common system tests

describe file('/etc/debian_version') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should contain('9') }
end

describe command('whoami') do
  let(:disable_sudo) { true }
  its(:stdout) { should match 'pi' }
end

describe command('whoami') do
  its(:stdout) { should match 'root' }
end

describe user('pi') do
  it { should have_uid 1000 }
  it { should have_login_shell '/bin/bash' }
  it { should have_home_directory '/home/pi' }
end

describe user('root') do
  it { should have_uid 0 }
  it { should have_login_shell '/bin/bash' }
  it { should have_home_directory '/root' }
end

describe file('/') do
   # be_mounted
   it { should be_mounted }
   # be_mounted_with_type
   it { should be_mounted.with( :type => 'ext4' ) }
   # be_mounted_with_options RW
   it { should be_mounted.with( :options => { :rw => true } ) }
end


# kernel
describe 'Linux kernel parameters' do
  context linux_kernel_parameter('kernel.sysrq') do
    its(:value) { should eq 1 }
  end

  context linux_kernel_parameter('net.ipv4.tcp_syncookies') do
    its(:value) { should eq 1 }
  end

  context linux_kernel_parameter('net.ipv6.conf.all.disable_ipv6') do
    its(:value) { should eq 1 }
  end

  context linux_kernel_parameter('net.ipv6.conf.eth0.disable_ipv6') do
    its(:value) { should eq 1 }
  end
end

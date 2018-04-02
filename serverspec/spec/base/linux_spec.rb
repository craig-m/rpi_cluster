require 'spec_helper'
# common system tests

describe file('/etc/debian_version') do
 it { should be_file }
 it { should be_owned_by 'root' }
end

describe command('whoami') do
  let(:disable_sudo) { true }
  its(:stdout) { should match 'pi' }
end

describe command('whoami') do
  its(:stdout) { should match 'root' }
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
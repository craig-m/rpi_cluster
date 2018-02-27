require 'spec_helper'
# common system tests

describe command('whoami') do
  let(:disable_sudo) { true }
  its(:stdout) { should match 'pi' }
end

describe command('whoami') do
  its(:stdout) { should match 'root' }
end

describe file('/') do
   # be_mounted
   it { should be_mounted }
   # be_mounted_with_type
   it { should be_mounted.with( :type => 'ext4' ) }
   # be_mounted_with_options RW
   it { should be_mounted.with( :options => { :rw => true } ) }
end

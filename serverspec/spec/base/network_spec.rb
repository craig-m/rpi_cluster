require 'spec_helper'

describe host('raspbian.raspberrypi.org') do
  let(:disable_sudo) { true }
  it { should be_resolvable }
  it { should be_reachable.with( :port => 80, :proto => 'tcp' ) }
end

describe host("github.com") do
  let(:disable_sudo) { true }
  it { should be_resolvable }
  it { should be_reachable.with( :port => 80, :proto => 'tcp' ) }
  it { should be_reachable.with( :port => 443, :proto => 'tcp' ) }
end

describe file('/etc/hosts') do
 its(:content) { should match /Ansible managed file/ }
 it { should be_file }
 it { should be_owned_by 'root' }
end

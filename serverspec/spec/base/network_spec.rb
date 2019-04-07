require 'spec_helper'

describe host('raspbian.raspberrypi.org') do
  it { should be_resolvable }
end

describe host("github.com") do
  it { should be_reachable.with( :port => 80, :proto => 'tcp' ) }
  it { should be_reachable.with( :port => 443, :proto => 'tcp' ) }
end

describe file('/etc/hosts') do
 its(:content) { should match /Ansible managed file/ }
 it { should be_file }
 it { should be_owned_by 'root' }
end

require 'spec_helper'

describe file('/opt/cluster/data/info_roles.txt') do
 it { should be_file }
 it { should be_owned_by 'root' }
 it { should be_mode 444 }
 its(:content) { should match /host-omega/ }
end

describe user('omegapyapi') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
end

# should not exist here
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

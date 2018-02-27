require 'spec_helper'

describe package('haveged') do
  it { should be_installed }
end

describe service('haveged') do
  it { should be_enabled }
  it { should be_running }
end

describe process("haveged") do
  its(:user) { should eq "root" }
  its(:count) { should eq 1 }
end

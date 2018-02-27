require 'spec_helper'

describe package('uptimed') do
  it { should be_installed }
end

describe service('uptimed') do
  it { should be_enabled }
  it { should be_running }
end

describe process("uptimed") do
  its(:user) { should eq "daemon" }
  its(:count) { should eq 1 }
end

require 'spec_helper'

describe package('ntp') do
  it { should be_installed }
end

describe service('ntp') do
  it { should be_enabled }
  it { should be_running }
end

describe process("ntpd") do
  its(:user) { should eq "ntp" }
end

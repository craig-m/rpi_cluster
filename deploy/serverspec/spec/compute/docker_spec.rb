require 'spec_helper'


describe package('docker.io') do
  it { should be_installed }
end


describe service('docker.service') do
  it { should be_enabled }
  it { should be_running }
end

require 'spec_helper'

describe service('docker.service') do
  it { should be_enabled }
  it { should be_running }
end

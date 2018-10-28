require 'spec_helper'

describe service('docker.service') do
  it { should be_enabled }
  it { should be_running }
end

describe group('docker') do
  it { should exist }
end

describe file('/etc/apt/sources.list.d/kubernetes.list') do
 it { should be_file }
 it { should be_owned_by 'root' }
 it { should be_grouped_into 'root' }
 it { should be_mode 644 }
end

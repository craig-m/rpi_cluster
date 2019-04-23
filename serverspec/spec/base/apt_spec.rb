require 'spec_helper'


# check there are no apt packages installed with critical vulns
# note: there might still be packages updates avail tho - just none marked with security issues
describe command('/usr/lib/nagios/plugins/check_apt --only-critical --timeout=30 --list') do
  its(:exit_status) { should eq 0 }
end


describe package('build-essential') do
  it { should be_installed }
end

describe package('apt-transport-https') do
  it { should be_installed }
end

describe package('monitoring-plugins-common') do
  it { should be_installed }
end

describe package('monitoring-plugins-basic') do
  it { should be_installed }
end

describe package('python-pip') do
  it { should be_installed }
end

describe package('wget') do
  it { should be_installed }
end

describe package('screen') do
  it { should be_installed }
end

describe package('busybox') do
  it { should be_installed }
end

describe package('git') do
  it { should be_installed }
end

describe package('ca-certificates') do
  it { should be_installed }
end

describe package('lsof') do
  it { should be_installed }
end

require 'spec_helper'

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

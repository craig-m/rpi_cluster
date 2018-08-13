require 'spec_helper'

describe package('pass') do
  it { should be_installed }
end

describe package('nmap') do
  it { should be_installed }
end

describe package('lynx') do
  it { should be_installed }
end

describe package('telnet') do
  it { should be_installed }
end

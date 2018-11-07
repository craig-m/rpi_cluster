require 'spec_helper'

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

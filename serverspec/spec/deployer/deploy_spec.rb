require 'spec_helper'

describe host("alpha") do
  it { should be_reachable }
end

describe host("beta") do
  it { should be_reachable }
end

describe host("omega") do
  it { should be_reachable }
end

# should not exist here
describe user('mpiuser') do
  it { should_not exist }
end
describe user('bind') do
  it { should_not exist }
end
describe user('omegapyapi') do
  it { should_not exist }
end
describe user('tftp') do
  it { should_not exist }
end
describe user('computeadm') do
  it { should_not exist }
end

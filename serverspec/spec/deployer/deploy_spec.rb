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


# /opt/cluster
describe file('/opt/cluster/data') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

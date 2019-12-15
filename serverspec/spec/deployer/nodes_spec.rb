require 'spec_helper'

# todo: for now we only have 8 nodes, this will not scale above that.

describe host("alpha") do
  it { should be_reachable }
  it { should be_reachable.with( :port => 22, :proto => 'tcp' ) }
end

describe host("beta") do
  it { should be_reachable }
  it { should be_reachable.with( :port => 22, :proto => 'tcp' ) }
end

describe host("gamma") do
  it { should be_reachable }
  it { should be_reachable.with( :port => 22, :proto => 'tcp' ) }
end

describe host("zeta") do
  it { should be_reachable }
  it { should be_reachable.with( :port => 22, :proto => 'tcp' ) }
end

describe host("delta") do
  it { should be_reachable }
  it { should be_reachable.with( :port => 22, :proto => 'tcp' ) }
end

describe host("epsilon") do
  it { should be_reachable }
  it { should be_reachable.with( :port => 22, :proto => 'tcp' ) }
end

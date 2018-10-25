require 'spec_helper'

describe host('debian.org') do
  it { should be_resolvable }
end

describe host("github.com") do
  it { should be_reachable.with( :port => 80, :proto => 'tcp' ) }
  it { should be_reachable.with( :port => 443, :proto => 'tcp' ) }
end

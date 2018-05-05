require 'spec_helper'

describe host('debian.org') do
  it { should be_resolvable }
end

describe host("#{property[:rpi_net_default_gw]}") do
  it { should be_reachable }
end

describe host("github.com") do
  it { should be_reachable.with( :port => 80, :proto => 'tcp' ) }
  it { should be_reachable.with( :port => 443, :proto => 'tcp' ) }
end

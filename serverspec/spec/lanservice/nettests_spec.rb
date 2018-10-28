require 'spec_helper'

describe port("#{property[:ssh_group_port]}") do
  it { should be_listening.with('tcp') }
end

# resolve internal hosts
describe host("omega.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
  # ping
  it { should be_reachable }
end

describe host("alpha.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
end

describe host("beta.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
end

describe host('google.com') do
  it { should be_resolvable }
end

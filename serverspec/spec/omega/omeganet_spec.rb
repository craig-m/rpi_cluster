require 'spec_helper'

describe host('google.com') do
  it { should be_resolvable }
end

describe host("alpha.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
end

describe host("beta.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
end

describe host("omega.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
end


describe host("www.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
end

describe host("float.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
  # ping
  it { should be_reachable }
end

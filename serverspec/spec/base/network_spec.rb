require 'spec_helper'

describe host('raspbian.raspberrypi.org') do
  it { should be_resolvable }
end

describe host("github.com") do
  it { should be_reachable.with( :port => 80, :proto => 'tcp' ) }
  it { should be_reachable.with( :port => 443, :proto => 'tcp' ) }
end


describe command("dig @alpha -t TXT txttest.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}  | grep -A1 ';; ANSWER SECTION:'") do
  its(:stdout) { should contain('txttest rpi_cluster_test').after('ANSWER SECTION') }
end

describe command("dig @beta -t TXT txttest.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}  | grep -A1 ';; ANSWER SECTION:'") do
  its(:stdout) { should contain('txttest rpi_cluster_test').after('ANSWER SECTION') }
end

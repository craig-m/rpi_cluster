require 'spec_helper'

describe port("#{property[:ssh_group_port]}") do
  it { should be_listening.with('tcp') }
end

# services shoult NOT be listening here
describe port(5353) do
  it { should_not be_listening }
end
describe port(443) do
  it { should_not be_listening }
end
describe port(80) do
  it { should_not be_listening }
end

# resolve internal hosts

describe host("alpha.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
end

describe host("beta.dc1.#{property[:rpi_cust_domain]}.#{property[:rpi_cust_tld]}") do
  it { should be_resolvable.by('dns') }
end

describe host('google.com') do
  it { should be_resolvable }
  let(:disable_sudo) { true }
end

require 'spec_helper'

describe package('ufw') do
  it { should be_installed }
end

describe iptables do
  it { should have_rule('-A INPUT -j ufw-reject-input') }
end
describe iptables do
  it { should have_rule('-A FORWARD -j ufw-reject-forward') }
end
describe iptables do
  it { should have_rule('-A OUTPUT -j ufw-reject-output') }
end
describe iptables do
  it { should have_rule('-A ufw-user-limit -j REJECT --reject-with icmp-port-unreachable') }
end

require 'spec_helper'

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

#describe iptables do
#  it { should have_rule("-A ufw-user-input -p tcp -m tcp --dport #{property[:ssh_group_port]} -j ACCEPT") }
#end

describe file('/root/ufw.sh') do
 it { should be_file }
end

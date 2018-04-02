require 'spec_helper'

describe iptables do
  it { should have_rule('-A ufw-user-input -p tcp -m tcp --dport 22 -j ACCEPT') }
end

describe iptables do
  it { should have_rule("-A ufw-user-input -p tcp -m tcp --dport #{property[:ssh_group_port]} -j ACCEPT") }
end

require 'spec_helper'


describe command('/usr/lib/nagios/plugins/check_procs -w 300 -c 400;') do
  its(:exit_status) { should eq 0 }
end

describe command('/usr/lib/nagios/plugins/check_users -w 10 -c 15') do
  its(:exit_status) { should eq 0 }
end

describe command('/usr/lib/nagios/plugins/check_disk -x /dev/sda1;') do
  its(:exit_status) { should eq 0 }
end

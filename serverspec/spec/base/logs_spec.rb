require 'spec_helper'

describe command('journalctl --verify') do
  its(:exit_status) { should eq 0 }
end

# find large log files
describe command('find /var/log/ -size +2M -exec ls {} -lah \;') do
  its(:stdout) { should match // }
end

# https://github.com/raspberrypi/linux/blob/39f45c408ab8f9cc9b9980f165e62eb92293b927/drivers/firmware/raspberrypi.c
# Under-voltage detected!
describe command('grep "Under-voltage detected!" /var/log/kern.log') do
  its(:stdout) { should match // }
end

# less than xx hits in firewall logs
describe command('test $(grep "UFW BLOCK" /var/log/kern.log | wc -l) -lt 50') do
  its(:exit_status) { should eq 0 }
end

# look for "Certificate invalid: expired" when our CA signed SSH key expires
describe command('journalctl -u ssh -n 100 | grep -i invalid') do
  its(:stdout) { should match // }
end

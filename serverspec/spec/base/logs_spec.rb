require 'spec_helper'

# find large log files
describe command('find /var/log/ -size +2M -exec ls {} -lah \;') do
  its(:stdout) { should match // }
end

# https://github.com/raspberrypi/linux/blob/39f45c408ab8f9cc9b9980f165e62eb92293b927/drivers/firmware/raspberrypi.c
# Under-voltage detected!
describe command('grep "Under-voltage detected!" /var/log/kern.log') do
  its(:stdout) { should match // }
end

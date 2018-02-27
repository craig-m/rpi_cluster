require 'spec_helper'

describe service('tftpd-hpa.service') do
  it { should be_enabled }
  it { should be_running }
  it { should be_running.under('systemd') }
end
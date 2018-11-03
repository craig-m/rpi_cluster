require 'spec_helper'


describe command('journalctl -u kubelet -n 20 | grep "Unable to update cni config"') do
  its(:stdout) { should match // }
end

require 'spec_helper'

# resolve google
describe host('debian.org') do
  it { should be_resolvable }
end

# ping Wifi host
describe host("#{property[:rpi_net_wifi_gw]}") do
  it { should be_reachable }
end

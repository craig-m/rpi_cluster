require 'spec_helper'

describe service('bbhttpd.service') do
  it { should be_enabled }
  it { should be_running }
  it { should be_running.under('systemd') }
end

describe file('/opt/chroot_bb/') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe host("localhost") do
  it { should be_reachable.with( :port => 1080, :proto => 'tcp' ) }
end

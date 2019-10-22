require 'spec_helper'

describe service('bbhttpd.service') do
  it { should be_enabled }
  it { should be_running }
  it { should be_running.under('systemd') }
end

describe user('bbweb') do
  it { should exist }
  it { should have_login_shell '/bin/false' }
end

describe file('/opt/chroot_bb/') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/opt/chroot_bb/www') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/opt/chroot_bb/etc') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/opt/chroot_bb/home') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe host("localhost") do
  it { should be_reachable.with( :port => 1080, :proto => 'tcp' ) }
  let(:disable_sudo) { true }
end

describe command('/usr/lib/nagios/plugins/check_http -p 1080 -I localhost -u /index.html -s "R-Pi BB httpd"') do
  its(:exit_status) { should eq 0 }
  let(:disable_sudo) { true }
end

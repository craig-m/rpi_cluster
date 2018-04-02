require 'spec_helper'

describe service('nginx.service') do
  it { should be_enabled }
  it { should be_running }
  it { should be_running.under('systemd') }
end

describe file('/etc/nginx/sites-enabled/omega.conf') do
 it { should be_file }
 it { should be_owned_by 'root' }
 its(:content) { should match /R-Pi Cluster Ansible managed file/ }
end

describe user('www-data') do
  it { should exist }
  it { should have_login_shell '/usr/sbin/nologin' }
end

describe file('/srv/nginx/default') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'root' }
end

describe file('/srv/nginx/hugo-site') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end
require 'spec_helper'

describe user('mpiuser') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
end

describe file('/srv/nfs_share') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe user('omegapyapi') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
end

describe file('/srv/python/omegapyapi/') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/srv/php/omegaapp/') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

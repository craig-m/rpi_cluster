require 'spec_helper'

describe user('mpiuser') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
end

describe file('/home/mpiuser/') do
 it { should be_directory }
 it { should be_owned_by 'mpiuser' }
 it { should be_grouped_into 'mpiuser' }
 it { should be_mode 700 }
end

require 'spec_helper'

describe user('distccd') do
  it { should exist }
  it { should have_login_shell '/bin/false' }
end

describe process("distccd") do
  its(:user) { should eq "distccd" }
end


describe file('/etc/distcc/hosts') do
 it { should be_file }
 it { should be_owned_by 'root' }
 it { should be_grouped_into 'root' }
 it { should be_mode 644 }
end

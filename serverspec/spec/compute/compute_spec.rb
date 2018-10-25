require 'spec_helper'

describe file('/opt/cluster/bin/compute-boot.sh') do
 it { should be_file }
 it { should be_owned_by 'root' }
 it { should be_grouped_into 'root' }
 its(:content) { should match /compute-boot.sh/ }
 it { should be_mode 770 }
end

describe package('openjdk-8-jdk') do
  it { should be_installed }
end

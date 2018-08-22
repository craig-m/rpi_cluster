require 'spec_helper'

describe host("alpha") do
  it { should be_reachable }
end

describe host("beta") do
  it { should be_reachable }
end

describe host("omega") do
  it { should be_reachable }
end

describe file('/home/pi/.password-store') do
  it { should be_mode 700 }
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/home/pi/.gnupg') do
  it { should be_mode 700 }
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/home/pi/.bundle') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/home/pi/.gem') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/home/mpiuser/') do
  it { should_not exist }
end

# /opt/cluster
describe file('/opt/cluster/data') do
  it { should be_mode 700 }
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/opt/cluster/backup') do
  it { should be_mode 770 }
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

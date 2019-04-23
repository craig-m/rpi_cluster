require 'spec_helper'

describe file('/home/pi/.rpibs') do
  it { should be_mode 770 }
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

describe file('/etc/ansible/ansible.cfg') do
 it { should be_file }
 it { should be_owned_by 'pi' }
 it { should be_grouped_into 'pi' }
 it { should be_mode 644 }
end

describe file('/etc/ansible/inventory/compute/hosts') do
 it { should be_file }
 it { should be_owned_by 'pi' }
 it { should be_grouped_into 'pi' }
 it { should be_mode 644 }
end
describe file('/etc/ansible/inventory/deploy/hosts') do
 it { should be_file }
 it { should be_owned_by 'pi' }
 it { should be_grouped_into 'pi' }
 it { should be_mode 644 }
end
describe file('/etc/ansible/inventory/lanservices/hosts') do
 it { should be_file }
 it { should be_owned_by 'pi' }
 it { should be_grouped_into 'pi' }
 it { should be_mode 644 }
end


describe file('/home/pi/.rpibs/completed') do
 it { should be_file }
end

describe file('/home/pi/.rpibs/setup-keys') do
 it { should be_file }
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

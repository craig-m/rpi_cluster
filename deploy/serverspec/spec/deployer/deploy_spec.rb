require 'spec_helper'


# /opt/cluster
describe file('/opt/cluster/data') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
end

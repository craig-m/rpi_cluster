require 'spec_helper'

describe file('/srv/nfs_share') do
  it { should be_directory }
  it { should be_owned_by 'pi' }
  it { should be_grouped_into 'pi' }
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

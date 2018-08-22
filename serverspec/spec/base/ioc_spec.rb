require 'spec_helper'

# should not be any exec files here
describe command('find /tmp/ -executable -type f') do
  its(:stdout) { should match // }
end

# running processes that have been deleted
describe command('lsof | grep deleted') do
  its(:stdout) { should match // }
end

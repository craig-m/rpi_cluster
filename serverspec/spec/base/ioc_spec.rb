require 'spec_helper'

# should not be any exec files here
describe command('find /tmp/ -executable -type f') do
  its(:stdout) { should match // }
end

# should not be any named pipes (FIFO) in tmp
describe command('find /tmp/ -type p') do
  its(:stdout) { should match // }
end

# look for queued jobs
describe command('atq') do
  its(:stdout) { should match // }
end

# running processes that have been deleted
describe command('lsof | grep deleted') do
  its(:stdout) { should match // }
end

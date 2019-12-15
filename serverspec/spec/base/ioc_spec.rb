require 'spec_helper'

# Docs / ToDo:
#
# "Detecting ATT&CK techniques & tactics for Linux"
# https://github.com/Kirtar22/Litmus_Test
#
#
# "Linux Atomic Tests by ATT&CK Tactic & Technique"
# https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/linux-index.md


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

require 'spec_helper'


#describe host("beta.local") do
#  it { should be_reachable }
#end


describe host('google.com') do
  it { should be_resolvable }
end

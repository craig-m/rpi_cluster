require 'spec_helper'

describe host('google.com') do
  it { should be_resolvable }
end

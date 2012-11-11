require 'rubygems'
require 'bundler/setup'

require "eetee"

include EEtee


describe 'Tests' do
  before do
    @a = 3
  end
  
  should 'have access to instance variables' do
    @a.should == 3
  end
  
  should 'works 2' do
    (40 + 5).should == 45
  end
  
  should 'fails' do
    "toto".should == 4
  end
  
  describe 'nested context' do
    should 'also have access to instance variables' do
      @a.should == 3
    end
  end
end

require 'rubygems'
require 'bundler/setup'

require "eetee"

include EEtee


Runner.new.run do
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



  describe 'another context' do
    should 'add 1+2' do
      (1+2).should == 3
    end
    
    should 'fails here' do
      4.should == 5
    end
  end
end


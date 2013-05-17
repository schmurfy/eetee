require 'rubygems'
require 'bundler/setup'
require "eetee"

include EEtee


shared(:valid_object) do |obj, n|
  should 'receive correct number' do
    n.should == 42
    obj.should == 'string'
  end
  
  should 'receive correct string' do
    obj.should == 'string'
  end
  
  should 'respond to :to_i' do
    obj.should.respond_to?(:to_i)
  end
  
  describe 'nested' do
    should 'have a length higher than 2' do
      obj.size.should > 2
    end
  end
end


describe 'Tests' do
  before do
    # clear database
  end
  
  run_shared(:valid_object, 'string', 42)
  
end

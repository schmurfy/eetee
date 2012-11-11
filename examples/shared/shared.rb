require 'rubygems'
require 'bundler/setup'
require "eetee"

include EEtee


shared(:valid_object) do |obj, n|
  should 'receive correct number' do
    n.should == 42
  end
  
  should 'respond to :to_i' do
    obj.should.respond_to?(:to_i)
  end
  
  should 'have a length higher than 2' do
    obj.size.should > 2
  end
end


describe 'Tests' do
  before do
    @obj = "string"
  end
  
  in_scope do
    run_shared(:valid_object, @obj, 42)
  end
  
end

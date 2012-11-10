require 'rubygems'
require 'bundler/setup'

require "eetee"

describe 'another context' do
  should 'add 1+2' do
    (1+2).should == 3
  end
  
  should 'fails here' do
    4.should == 5
  end
end

require 'rubygems'
require 'bundler/setup'

require 'eetee'

require_relative 'extension'
EEtee::Test.__send__(:include, SimpleExtension)

describe 'context' do
  should 'use extension' do
    true.should == true
  end
end

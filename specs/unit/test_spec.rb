require_relative '../spec_helper'

describe 'Test' do
  before do
    @reporter = stub('Reporter')
    @reporter.stubs(:around_test).yields
  end
  
  should 'execute given block in context' do
    a = 4
    
    # do not contaminate current thread variables
    # required because we are running a test inside a test which
    # should never happen in normal conditions
    Thread.new do
      tt = EEtee::Test.new("a test", @reporter) do
        a = 5
      end
    end.join
    
    a.should == 5
  end
  
  
  should 'wrap errors in EEtee::Error' do
    
    err = ->{
      Thread.new do
        EEtee::Test.new("a test", @reporter) do
          raise "error"
        end
      end.join
    }.should.raise(EEtee::Error)
    
    err.error.should.be_a RuntimeError
    err.error.message.should == "error"
  end
  
  
  should 'be extensible' do
    NewTest = Class.new(EEtee::Test) do
      include SimpleExtension
    end
    
    tmp = nil
    a = nil
    
    th = Thread.new do
      NewTest.new("a test", @reporter){ a = 7 }
    end.join
    
    a.should == 7
    th[:eetee_simple_extension].should == [1, 2]
  end
  
end

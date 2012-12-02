require File.expand_path('../../spec_helper', __FILE__)

describe 'Test' do
  before do
    @reporter = stub('Reporter')
    @reporter.stubs(:increment_assertions)
    @reporter.stubs(:around_test).yields
    EEtee.stubs(:current_reporter).returns(@reporter)
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
    
    err = nil
    Thread.new do
      begin
        EEtee::Test.new("a test", @reporter) do
          raise "error"
        end
      rescue => ex
        err = ex
      end
    end.join
      
    err.should.be_a EEtee::Error
    
    err.error.should.be_a RuntimeError
    err.error.message.should == "error"
    err.test.should.be_a EEtee::Test
  end
  
  should 'associate current test to raised assertions' do
    err = nil
    Thread.new do
      begin
        EEtee::Test.new("a test", @reporter) do
          1.should == 2
        end
      rescue => ex
        err = ex
      end
    end.join
    
    err.should.be_a EEtee::AssertionFailed
    err.test.should.be_a EEtee::Test
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

require File.expand_path('../../spec_helper', __FILE__)

describe 'Context' do
  before do
    @reporter = stub('Reporter')
    @reporter.stubs(:around_context).yields
    @reporter.stubs(:around_test).yields
  end
  
  should 'run block in context' do
    a = nil
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter, :@a => 34) do
        a = @a
      end
    end.join
    a.should == 34
  end
  
  should 'run before block in same context' do
    a = nil
    Thread.new do
      ctx = EEtee::Context.new("a context", 0, @reporter, :@a => 234){ }
      ctx.before{ a = @a }
    end.join
    a.should == 234
  end
  
  should 'copy instance variables in nested contexts' do
    a = b = nil
    Thread.new do
      ctx = EEtee::Context.new("a context", 0, @reporter, :@a => 98, :@b => "string"){ }
      ctx.describe("nested context"){ a = @a; b = @b }
    end.join
    a.should == 98
    b.should == "string"
  end
  
  should 'create a test' do
    EEtee::Test.expects(:new).with("a test", @reporter)
    Thread.new do
      ctx = EEtee::Context.new("a context", 0, @reporter, :@a => 98, :@b => "string"){ }
      ctx.should("a test"){ 1.should == 1 }
    end.join
  end
  
end

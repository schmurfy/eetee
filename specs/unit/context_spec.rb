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
    err = nil
    EEtee::Test.expects(:new).with("should test something", @reporter)
    Thread.new do
      begin
        ctx = EEtee::Context.new("a context", 0, @reporter, :@a => 98, :@b => "string"){ }
        ctx.should("test something"){ 1.should == 1 }
      rescue Exception => ex
        err = ex
      end
    end.join
    
    err.should == nil
  end
  
  should 'only run focused test' do
    err = nil
    n = 0
    
    Thread.new do
      begin
        ctx = EEtee::Context.new("a context", 0, @reporter, {:@a => 98, :@b => "string"}, true){ }
        ctx.should("test something", :focus => true){ n = 1 }
        ctx.should("test something"){ n = 2 }
      rescue Exception => ex
        err = ex
      end
    end.join
    
    n.should == 1
    err.should == nil
  end
  
  should 'only run focused test (nested context)' do
    err = nil
    n = 0
    
    Thread.new do
      begin
        ctx = EEtee::Context.new("a context", 0, @reporter, {:@a => 98, :@b => "string"}, true){ }
        ctx2 = ctx.describe("nested"){}
        ctx2.should("test something", :focus => true){ n = 1 }
        ctx2.should("test something"){ n = 2 }
      rescue Exception => ex
        err = ex
      end
    end.join
    
    n.should == 1
    err.should == nil
  end
  
end

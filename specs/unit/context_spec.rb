require File.expand_path('../../spec_helper', __FILE__)

describe 'Context' do
  before do
    @reporter = stub('Reporter')
    @reporter.stubs(:around_context).yields
    @reporter.stubs(:around_test).yields
  end
  
  should 'run block in context' do
    a = nil
    test_th_id = nil
    
    @reporter.stubs(:increment_assertions)
    
    th_id = Thread.current.object_id
    
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter, :@a => 34) do
        test_th_id = Thread.current.object_id
        a = @a
      end
    end.join
    
    th_id.should.not == test_th_id
    a.should == 34
  end
  
  should 'run before block in same context' do
    a = nil
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter, :@a => 234) do
        before{ a = @a }
        should("do nothing"){} # just to run the before block
      end
    end.join
    a.should == 234
  end
  
  should 'allow tests to use the context description' do
    a = nil
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter, :@a => 234) do
        should("do nothing"){ a = context_description() }
      end
    end.join
    a.should == "a context"
  end
  
  should 'allow tests to use the nested context description' do
    a = nil
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter, :@a => 234) do
        describe("sub context") do
          should("do nothing"){ a = context_description() }
        end
      end
    end.join
    a.should == "sub context"
  end
  
  should 'run after block in same context' do
    a = nil
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter, :@a => 234) do
        after{ a = @a }
        should("do nothing"){} # just to run the before block
      end
    end.join
    a.should == 234
  end
  
  
  should 'run the before blocks before every test' do
    n = 0
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter) do
        before{ n = 1 }
        should("test 1"){ n += 2 }
        should("test 2"){ n += 2 }
      end
    end.join
    n.should == 3
  end
  
  should 'run the after blocks after every test' do
    n = 0
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter) do
        after{ n = 1 }
        should("test 1"){ n += 2 }
        should("test 2"){ n += 2 }
      end
    end.join
    n.should == 1
  end
  
  should 'run the after blocks after when an error occured in test' do
    n = 0
    Thread.new do
      begin
        EEtee::Context.new("a context", 0, @reporter) do
          after{ n = 1 }
          should("test 1"){ raise "toto" }
        end
      rescue
      end
    end.join
    n.should == 1
  end
  
  should 'only run the rigth before blocks' do
    n = 0
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter) do
        before{ n = 1 }
        
        describe("sub context") do
          before { n = 10 }
        end
        
        should("test 1"){ n += 2 }
      end
    end.join
    n.should == 3
  end
  
  should 'copy instance variables in nested contexts' do
    a = b = nil
    Thread.new do
      EEtee::Context.new("a context", 0, @reporter, :@a => 98, :@b => "string") do
        describe("nested context"){ a = @a; b = @b }
      end
    end.join
    a.should == 98
    b.should == "string"
  end
  
  should 'create a test' do
    err = nil
    EEtee::Test.expects(:new).with("should test something", @reporter)
    Thread.new do
      begin
        EEtee::Context.new("a context", 0, @reporter, :@a => 98, :@b => "string") do
          should("test something"){ 1.should == 1 }
        end
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
        EEtee::Context.new("a context", 0, @reporter, {:@a => 98, :@b => "string"}, true) do
          should("test something", :focus => true){ n = 1 }
          should("test something"){ n = 2 }
        end
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
        EEtee::Context.new("a context", 0, @reporter, {:@a => 98, :@b => "string"}, true) do
          describe("nested") do
            should("test something", :focus => true){ n = 1 }
            should("test something"){ n = 2 }
          end
        end
      rescue Exception => ex
        err = ex
      end
    end.join
    
    n.should == 1
    err.should == nil
  end
  
end

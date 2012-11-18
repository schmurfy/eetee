require File.expand_path('../../spec_helper', __FILE__)

describe 'Shared' do
  before do
    @reporter = stub('Reporter')
    @reporter.stubs(:around_context).yields
    @reporter.stubs(:around_test).yields
  end
  
  should 'run block in context' do
    a = nil
    
    shared = EEtee::Shared.new(:shared1) do |opts|
      a = opts[:arg1]
    end
    
    shared.run(:arg1 => 54)
    
    a.should == 54
  end
  
  should 'run block in context (with class)' do
    a = nil
    
    shared = EEtee::Shared.new(:shared1) do |opts|
      a = opts[:arg1]
    end
    
    EEtee::Shared.run(:shared1, @reporter, 0, :arg1 => 54)
    
    a.should == 54
  end


end

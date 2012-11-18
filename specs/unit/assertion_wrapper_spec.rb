require File.expand_path('../../spec_helper', __FILE__)

module Helpers
  def ensure_error_not_raised
    ret = nil
    begin
      yield
    rescue => err
      ret = err
    end
    
    ret.should == nil
  end
  
  def ensure_error_raised(error_class)
    ret = nil
    begin
      yield
    rescue error_class => err
      ret = err
    end
    
    ret.class.should == error_class
  end
end

EEtee::Context.__send__(:include, Helpers)

describe 'AssertionWrapper' do
  before do
    @obj = stub('Object')
    @wrapper = EEtee::AssertionWrapper.new(@obj)
  end
  
  should 'call method on the targeted object' do
    @obj.expects(:to_zebra).returns(3)
    @wrapper.to_zebra
  end
  
  should 'not raise an error if methods return anything else' do
    @obj.expects(:to_zebra).returns(3)
    ensure_error_not_raised do
      @wrapper.to_zebra
    end
  end
  
  
  describe 'assertions' do
    describe 'any method' do
      should 'not raise an error if it returns a non false value' do
        @obj.expects(:to_zebra).returns(3)
        @wrapper.to_zebra
      end
      
      should 'raise an error if it returns a false/nil value' do
        @obj.expects(:to_zebra).returns(nil)
        ensure_error_raised(EEtee::AssertionFailed) do
          @wrapper.to_zebra
        end
      end
      
      should '[inverted] not raise an error if it returns a false/nil value' do
        @obj.expects(:to_zebra).returns(nil)
        ensure_error_not_raised do
          @wrapper.not.to_zebra
        end
      end
    end
    
    describe 'raise' do
      should 'raise an error if block do not raises expected error' do
        @obj.expects(:to_zebra).raises("damn !")
        ensure_error_raised(EEtee::AssertionFailed) do
          ->{ @wrapper.to_zebra }.should.raise(NoMethodError)
        end
      end
      
      should 'not raise an error if block raises expected error' do
        @obj.expects(:to_zebra).raises("damn !")
        ensure_error_not_raised do
          ->{ @wrapper.to_zebra }.should.raise(RuntimeError)
        end
      end
      
      should '[inverted] raise an error if block raises expected error' do
        @obj.expects(:to_zebra).raises("damn !")
        ensure_error_raised(EEtee::AssertionFailed) do
          ->{ @wrapper.to_zebra }.should.not.raise(RuntimeError)
        end
      end

    end
    
    describe 'be_a' do
      should 'not raise an error if class match' do
        w1 = EEtee::AssertionWrapper.new("string")
        w1.be_a String
        
        w1 = EEtee::AssertionWrapper.new(4)
        w1.be_a Fixnum
      end
      
      should 'raise an error unless class match' do
        w1 = EEtee::AssertionWrapper.new("string")
        ->{ w1.be_a Fixnum }.should.raise(EEtee::AssertionFailed)
        
        w1 = EEtee::AssertionWrapper.new(3)
        ->{ w1.be_a String }.should.raise(EEtee::AssertionFailed)
      end

    end
    
    describe 'be' do
      should 'be transparent (syntax sugar)' do
        w1 = EEtee::AssertionWrapper.new("string")
        w1.be == "string"
      end
    end
    
    
  end
  
end

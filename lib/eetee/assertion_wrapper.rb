module EEtee
  
  module Assertions
    def be_a(klass)
      object_class = @object.class
      
      invert_helper(
        "expected instance of #{klass}, got #{object_class}",
        "instance of #{klass} not expected"
      ) do
        object_class.should == klass
      end
      
    end
    
    def raise(expected_error_class = RuntimeError)
      @object.should.be_a ::Proc
      err = nil
      begin
        @object.call()
      rescue => ex
        err = ex
      end
      
      error_message = err ? err.message : ""
      fail_message = err ? "#{err.class} (#{error_message})" : "no error"
      
      invert_helper(
        "expected to raise #{expected_error_class}, got #{fail_message}",
        "expected not to raise #{expected_error_class} (#{error_message})"
      ) do
        err.class.should == expected_error_class
      end
      
      err
    end
    
    def close?(target, error_margin)
      invert_helper(
        "expected #{target} += #{error_margin}, got #{@object}",
        "expected to be outside of #{target} += #{error_margin}, got #{@object}"
      ) do
        (target-error_margin .. target+error_margin).should.include?(@object)
      end
    end
    
  end
  
  class AssertionWrapper < BasicObject
    
    instance_methods.each do |name|
      if name =~ /\?|^\W+$/
        undef_method(name)
      end
    end
    
    include Assertions
    
    def initialize(object)
      @object = object
      @invert = false
    end
    
    def method_missing(name, *args, &block)
      ::EEtee.current_reporter.increment_assertions()
      
      ret = @object.__send__(name, *args, &block)
      
      if !!ret == !!@invert
        if ((name == :'==') || (name == :'!=')) && (@object.is_a?(::String) && args[0].is_a?(::String))
          msg = "\n#{@object}\n#{name}\n#{args[0]}\n=> #{ret} (size: #{@object.size} / #{args[0].size})"
        elsif args.empty?
          msg = "#{@object.inspect}.#{name}() => #{ret}"
        else
          msg = "#{@object.inspect}.#{name}(#{args}) => #{ret}"
        end
        
        ::Kernel.raise AssertionFailed.new("#{@invert ? '[not] ' : ''}#{msg}")
      end
    end
    
    def not
      @invert = true
      self
    end
    
    def be
      self
    end
  
  private
    ##
    # invert result if needed.
    def invert_helper(message, invert_message)
      err = nil
      
      begin
        ret = yield
      rescue AssertionFailed => ex
        err = ex
      end
      
      if err || @invert
        ::Kernel.raise AssertionFailed.new(@invert ? invert_message : message)
      end
      
      ret
    end
  
  end
  
end

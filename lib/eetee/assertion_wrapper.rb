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
    
    def raise(error_class = RuntimeError)
      @object.should.be_a ::Proc
      
      err = nil
      begin
        self.call()
      rescue => ex
        err = ex
      end
      
      invert_helper(
        "expected to raise #{error_class}, got #{err.class} (#{err.message})",
        "expected not to raise #{error_class} (#{err.message})"
      ) do
        err.class.should == error_class
      end
      
      err
    end
    
    def close?(target, error_margin)
      invert_helper(
        "expected #{target} += #{error_margin}, got #{target}",
        "expected to be outside of #{target} += #{error_margin}, got #{target}"
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
        if args.empty?
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

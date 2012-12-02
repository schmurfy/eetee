module EEtee
  class Reporter
    attr_reader :failures, :errors, :assertion_count, :test_count
    
    def initialize
      @errors = []
      @failures = []
      @empty = []
      
      @indent = 0
      @assertion_count = 0
      @test_count = 0
      
      @started_at = Time.now
    end
    
    def increment_assertions
      @assertion_count += 1
    end
    
    ##
    # Declare an error, only use this
    # when we are "outside" of the current
    # flow like with EventMachine
    # 
    # @param [RuntimeError] an error
    def add_error(err)
      @errors << err
    end
    
    def around_context(ctx, &block)
      @indent += 1
      block.call()
    ensure
      @indent -= 1
    end
    
    def around_test(test, &block)
      before_assertions = @assertion_count
      
      block.call()
      
      if before_assertions == @assertion_count
        @empty << test
        :empty
      else
        @test_count += 1
        :ok
      end
      
    rescue EEtee::AssertionFailed => err
      @failures << err
      :failed
      
    rescue EEtee::Error => err
      @errors << err
      :error
    end
    
  end
  
  
  def report_results
    # no op
  end

private
  def elapsed_time
    Time.now.to_i - @started_at.to_i
  end
  
end

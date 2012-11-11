require 'thread'

module EEtee
  
  module TestBaseExtension
    def run(&block)
      block.call()
    end
  end
  
  class Test
    attr_reader :label, :reporter
    
    include TestBaseExtension
    
    def initialize(label, reporter, &block)
      @label = label
      @reporter = reporter || raise('missing reporter')
      @reporter.around_test(self) do
        run(&block)
      end
    end
    
    def run(&block)
      EEtee.current_test = self
      super(&block)
            
    rescue AssertionFailed => err
      err.test = self
      ::Kernel.raise
      
    rescue => err
      ::Kernel.raise Error.new(err, self)
    ensure
      EEtee.current_test = nil
    end
    
  end

end


require 'fiber'

gem 'eventmachine'
require 'eventmachine'

module EEtee::EMSpec
  class << self
    attr_accessor :context_fiber
  end
  
  def wakeup
    # this should be enough but for some reason the reactor
    # idles for 20 seconds on EM::stop before really exiting
    # @waiting_fiber.resume
    
    if @waiting_fiber
      EM::next_tick { @waiting_fiber.resume }
    end
  end
  
  def wait(timeout = 0.1, &block)
    @waiting_fiber = Fiber.current
    EM::cancel_timer(@timeout)
    @timeout = EM::add_timer(timeout, &method(:wakeup))
    
    Fiber.yield
    
    @waiting_fiber = nil
    
    block.call if block
  end
  
  def done
    EM.cancel_timer(@timeout)
    wakeup
  end
  
  def new_fiber(&block)
    Fiber.new(&block).resume
  end
  
  def run(&block)
    if EMSpec.context_fiber == Fiber.current
      block.call()
    else
      EM::run do
        EM::error_handler do |err|
          test = EEtee.current_test || EEtee::Test.new("(EM Loop)", @_reporter){}
          @_reporter.add_error( EEtee::Error.new(err, test))
        end
        
        new_fiber do
          EMSpec.context_fiber = Fiber.current
          begin
            block.call()
            EM::stop_event_loop
          ensure
            EMSpec.context_fiber = nil
          end
        end
        
      end
      
    end
  end
  
  
end

EEtee::Context.__send__(:include, EEtee::EMSpec)

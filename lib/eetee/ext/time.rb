module EEteeTimeHelpers
  def time_block
    started_at = Time.now
    yield
    (Time.now - started_at) * 1000
  end
  
  # load the mocha extension first to enable
  # this.
  if defined?(MochaCounterWrapper)
    ##
    # Freeze the time, in this block Time.now
    # will always return the same value.
    def self.freeze_time(t = Time.now)
      Time.stubs(:now).returns(t)
      if block_given?
        begin
          yield
        ensure
          Time.unstub(:now)
        end
      end
    end
    
    def freeze_time(*args, &block)
      EEteeTimeHelpers.freeze_time(*args, &block)
    end
  end
  
end

EEtee::Context.__send__(:include, EEteeTimeHelpers)

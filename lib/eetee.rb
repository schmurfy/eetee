require_relative 'eetee/version'

require_relative 'eetee/reporter'
require_relative 'eetee/reporters/text'
require_relative 'eetee/reporters/console'

require_relative 'eetee/errors'
require_relative 'eetee/assertion_wrapper'
require_relative 'eetee/test'
require_relative 'eetee/context'
require_relative 'eetee/shared'
require_relative 'eetee/runner'



module EEtee
  class << self
    def default_reporter_class=(reporter)
      @reporter = reporter
    end
    
    def default_reporter_class
      @reporter
    end
    
    def enable_focus_mode=(value)
      @enable_focus_mode = value
    end
    
    def enable_focus_mode
      @enable_focus_mode
    end
  end
  
  
  def self.current_test
    Thread.current[:eetee_test]
  end
  
  def self.current_test=(test)
    Thread.current[:eetee_test] = test
  end
  
  
  module AssertionHelpers
    def should()
      EEtee::AssertionWrapper.new(self)
    end
  end

  def describe(description, enable_focus_mode = EEtee.enable_focus_mode, &block)
    reporter = EEtee.default_reporter_class.new
    Context.new(description, 0, reporter, {}, enable_focus_mode, &block)
    reporter.report_results()
  end
  
  def shared(name, &block)
    Shared.new(name, &block)
  end
  
  self.default_reporter_class = Reporters::Console
end

include EEtee
Object.__send__(:include, EEtee::AssertionHelpers)

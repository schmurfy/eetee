require_relative 'eetee/version'

require_relative 'eetee/reporter'
require_relative 'eetee/reporters/text'
require_relative 'eetee/reporters/console'

require_relative 'eetee/errors'
require_relative 'eetee/assertion_wrapper'
require_relative 'eetee/test'
require_relative 'eetee/context'
require_relative 'eetee/runner'

require_relative 'eetee/ext/mocha'



module EEtee
  class << self
    def default_reporter_class=(reporter)
      @reporter = reporter
    end
    
    def default_reporter_class
      @reporter
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

  def describe(description, &block)
    reporter = EEtee.default_reporter_class.new
    Context.new(description, 0, reporter, &block)
    reporter.report_results()
  end
  
  self.default_reporter_class = Reporters::Console
end

include EEtee
Object.__send__(:include, EEtee::AssertionHelpers)

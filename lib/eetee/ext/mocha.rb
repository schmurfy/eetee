gem 'mocha', '~> 0.12.0'
require 'mocha_standalone'

#
# This extension ensure that mocha expectations are considered
# as bacon tests. Amongst other thing it allows to have a test
# containing only mocha expectations.
class MochaCounterWrapper
  def initialize(reporter)
    @reporter = reporter
  end
  
  def increment
    @reporter.increment_assertions()
  end
end



module MochaSpec
  def self.included(klass)
    klass.__send__(:include, Mocha::API)
  end
  
  def run(&block)
    super{ run_with_mocha(&block) }
  end
    
private
  def run_with_mocha(&block)
    begin
      mocha_setup
      block.call
      mocha_verify(MochaCounterWrapper.new(@reporter))
    rescue Mocha::ExpectationError => e
      raise EEtee::AssertionFailed.new(e.message)
      # raise EEte::Error.new(:failed, "#{e.message}\n#{e.backtrace[0...10].join("\n")}")
    ensure
      mocha_teardown
    end
  end
  
end

EEtee::Context.__send__(:include, Mocha::API)
EEtee::Test.__send__(:include, MochaSpec)


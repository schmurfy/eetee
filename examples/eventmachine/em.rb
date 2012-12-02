require 'rubygems'
require 'bundler/setup'

require 'eetee'
require 'eetee/ext/em'

describe 'context' do
  before do
    @fib = Fiber.current
  end
  
  should 'run in a fiber inside EventMachine' do
    @fib.should == Fiber.current
    EM.reactor_running?.should == true
  end
  
  describe 'nested context' do
    should 'run in a fiber inside EventMachine' do
      @fib.should == Fiber.current
      EM.reactor_running?.should == true
    end
  end
end

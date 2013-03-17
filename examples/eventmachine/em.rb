require 'rubygems'
require 'bundler/setup'

require 'eetee'
require 'eetee/ext/mocha'
require 'eetee/ext/em'

class EMHandler < EM::Connection
  def initialize(arg)
    @arg = arg
  end
  
  def receive_data(data)
    @arg.toto()
  end
end



describe 'context' do
  before do
    @fib = Fiber.current
    @port = 23456 + rand(100)
    @srv = EM::start_server('127.0.0.1', @port, EMHandler, mock('Trash'))
  end
  
  should 'wait packet (and fails)' do
    
    socket = EM::connect('127.0.0.1', @port)
    
    EM::add_timer(0.1) do
      socket.send_data("data")
    end
    
    wait(1)
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

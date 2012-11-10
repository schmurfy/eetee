require_relative 'eetee/version'

class Reporter
  def initialize
    @errors = []
    @failures = []
    @indent = 0
  end
  
  def around_context(ctx)
    puts "" if @indent == 0
    iputs "# #{ctx.description}:"
    @indent += 1
    yield
  ensure
    @indent -= 1
  end
  
  def around_test(test)
    iprint "- #{test.label}... "
    yield
    puts "SUCCES"
    
  rescue EEtee::AssertionFailed => err
    @failures << err
    puts "FAILED"
    
  rescue EEtee::Error => err
    @errors << err
    puts "ERROR"
  end
  
  def report_results
    puts "Completed with #{@errors.size} errors and #{@failures.size} failures"
    
    puts "\nFailures:"
    @failures.each do |f|
      p [f.test.label, f.message]
    end
    
    
    puts "\nErrors:"
    @errors.each do |err|
      p [err.test.label, err.error]
      
    end
  end

private
  def iprint(msg)
    tmp = '  ' * @indent
    Kernel.print("#{tmp}#{msg}")
  end

  def iputs(msg)
    iprint("#{msg}\n")
  end
end




# 1.should == 5
class Object
  def should()
    EEtee::AssertionWrapper.new(self)
  end
end



module EEtee
  class AssertionFailed < RuntimeError
    attr_accessor :test
        
  end
  
  class Error < RuntimeError
    attr_accessor :error, :test
    
    def initialize(error, test)
      @error = error
      @test = test
    end
  end
  
  class AssertionWrapper < BasicObject
    instance_methods.each do |name|
      if name =~ /\?|^\W+$/
        undef_method(name)
      end
    end
    
    def initialize(object)
      @object = object
    end
    
    def method_missing(name, *args)
      unless @object.__send__(name, *args)
        ::Kernel.raise AssertionFailed.new("#{@object}.#{name}(#{args})")
      end
    end
    
  end
  
  class Test
    attr_reader :label
    
    def initialize(label, reporter, &block)
      @label = label
      @reporter = reporter
      @reporter.around_test(self) do
        run(&block)
      end
    end
    
    def run(&block)
      block.call()
      
    rescue AssertionFailed => err
      err.test = self
      ::Kernel.raise
      
    rescue => err
      ::Kernel.raise Error.new(err, self)
    end
    
  end
  
  class Context
    attr_reader :description, :level
    
    def initialize(description, level, reporter, &block)
      @description = description
      @level = level
      @reporter = reporter
      @reporter.around_context(self) do
        instance_eval(&block)
      end
    end
    
    def before(&block)
      instance_eval(&block)
    end
    
    def describe(description, &block)
      Context.new(description, @level + 1, @reporter, &block)
    end
    
    def should(label, &block)
      Test.new(label, @reporter, &block)
    end
    
  end
  
  
  def describe(description, reporter_class = Reporter, &block)
    reporter = reporter_class.new
    Context.new(description, 0, reporter, &block)
    reporter.report_results()
  end
  
  class Runner
    def initialize(reporter_class = Reporter)
      @reporter = reporter_class.new
    end
    
    def run(&block)
      instance_eval(&block)
      @reporter.report_results()
    end
    
    def run_files(pattern)
      Dir[pattern].each do |path|
        data = File.read(path)
        instance_eval(data, path)
      end
      
      @reporter.report_results()
      
    rescue SyntaxError => ex
      puts ex.message
    end
    
    def describe(description, &block)
      Context.new(description, 0, @reporter, &block)
    end
  end
end

include EEtee


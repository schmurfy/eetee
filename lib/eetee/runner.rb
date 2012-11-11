require 'forwardable'

module EEtee
    
  class Runner
    extend Forwardable
    
    def_delegators :@reporter, :failures, :errors, :assertions, :test_count
    
    def initialize
      @reporter = EEtee.default_reporter_class.new
    end
    
    def run(&block)
      instance_eval(&block)
      @reporter.report_results()
    end
    
    def run_pattern(pattern)
      paths = []
      caller_path = caller[0].split(':').first
      pattern = File.expand_path("../#{pattern}", caller_path)
      
      paths = Dir[pattern].to_a
      run_files(paths)
    end
    
    ##
    # run the files relative to the caller.
    # 
    def run_files(paths)
      paths.each do |path|
        if File.exist?(path)
          data = File.read(path)
          instance_eval(data, path)
        else
          puts "!!! file does not exists: #{path}"
        end
      end
      
    rescue SyntaxError => ex
      puts ex.message
    end
    
    def report_results
      @reporter.report_results()
    end
    
    def describe(description, &block)
      Context.new(description, 0, @reporter, &block)
    end
  end
  
end

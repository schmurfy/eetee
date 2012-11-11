module EEtee
    
  class Runner
    def initialize
      @reporter = EEtee.default_reporter_class.new
    end
    
    def run(&block)
      instance_eval(&block)
      @reporter.report_results()
    end
    
    ##
    # run the files relative to the caller.
    # 
    def run_files(pattern)
      caller_path = caller[0].split(':').first
      pattern = File.expand_path("../#{pattern}", caller_path)
      
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

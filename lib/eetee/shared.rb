module EEtee
  class Shared
    attr_accessor :_reporter
    
    @@shared = {}
    
    def self.run(name, reporter, *args)
      sh = @@shared[name]
      sh._reporter = reporter
      sh.run(*args)
    end
    
    
    def initialize(name, &block)
      @@shared[name] = self
      @_block = block
    end
    
    def run(*args)
      instance_exec(*args, &@_block)
    end
    
    def should(label, &block)
      Test.new(label, _reporter, &block)
    end
    
  end
end

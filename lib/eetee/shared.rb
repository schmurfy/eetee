module EEtee
  class Shared
    attr_accessor :_reporter, :_level
    
    include SharedContextMethods
    
    @@shared = {}
    
    def self.run(name, reporter, level, *args)
      sh = @@shared[name]
      sh._reporter = reporter
      sh._level = level
      sh.run(*args)
    end
    
    
    def initialize(name, &block)
      @@shared[name] = self
      @_block = block
    end
    
    def run(*args)
      instance_exec(*args, &@_block)
    end
    
  end
end

module EEtee
    
  class Context
    attr_reader :description, :level
    
    def description; @_description; end
    def level; @_level; end
    
    def initialize(description, level, reporter, vars = {}, &block)
      vars.each do |name, value|
        instance_variable_set(name, value)
      end
      
      @_description = description
      @_level = level
      @_reporter = reporter
      @_reporter.around_context(self) do
        run(&block)
      end
    end
    
    def run(&block)
      instance_eval(&block)
    end
    
    def before(&block)
      instance_eval(&block)
    end
    
    def describe(description, &block)
      vars = {}
      
      instance_variables.reject{|name| name.to_s.start_with?('@_') }.each do |name|
        value = instance_variable_get(name)
        vars[name] = value
      end
      
      Context.new(description, @_level + 1, @_reporter, vars, &block)
    end
    
    def should(label, &block)
      Test.new(label, @_reporter, &block)
    end
  end

end

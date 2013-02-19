module EEtee
  
  NOT_CLONEABLE_TYPES = [Fixnum, NilClass, TrueClass, FalseClass].freeze
    
  module SharedContextMethods
    def before(&block)
      @before ||= []
      @before << block
    end
    
    def after(&block)
      @after ||= []
      @after << block
    end
    
    def describe(description, &block)
      vars = {}
      
      instance_variables.reject{|name| name.to_s.start_with?('@_') }.each do |name|
        value = instance_variable_get(name)
        if NOT_CLONEABLE_TYPES.include?(value.class)
          vars[name] = value
        else
          vars[name] = value.clone
        end
      end
      
      Context.new(description, @_level + 1, @_reporter, vars, @_focus_mode, &block)
    end
    
    def should(label, opts = {}, &block)
      it("should #{label}", opts, &block)
    end
        
    def it(label, opts = {}, &block)
      if !@_focus_mode || opts[:focus]
        begin
          (@before || []).each{|b| instance_eval(&b) }
          Test.new(label, @_reporter, &block)
        ensure
          (@after || []).each{|b| instance_eval(&b) }
        end
      end
    end
  end
  
  class Context
    attr_reader :description, :level
    
    include SharedContextMethods
    
    def description; @_description; end
    def level; @_level; end
    
    alias_method :context_description, :description
    
    def initialize(description, level, reporter, vars = {}, focus_mode = false, &block)
      vars.each do |name, value|
        instance_variable_set(name, value)
      end
      
      @_focus_mode = focus_mode
      
      @_description = description
      @_level = level
      @_reporter = reporter
      @_reporter.around_context(self) do
        run(&block)
      end
    end
    
    def run(&block)
      run = ->{
        EEtee.current_reporter = @_reporter
        instance_eval(&block)
      }
      
      if defined? super
        super(&run)
      else
        run.call()
      end
    end
    
    def run_shared(name, *args)
      Shared.run(name, @_reporter, @_level, *args)
    end
    
    def in_scope(&block)
      instance_eval(&block)
    end
    
  end

end

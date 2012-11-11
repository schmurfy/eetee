module EEtee
  module Reporters
    
    class Text
      attr_reader :failures, :errors, :assertion_count, :test_count
      
      def initialize
        @errors = []
        @failures = []
        @empty = []
        
        @indent = 0
        @assertion_count = 0
        @test_count = 0
      end
      
      def increment_assertions
        @assertion_count += 1
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
        before_assertions = @assertion_count
        
        iprint "- #{test.label}... "
        yield
        
        if before_assertions == @assertion_count
          puts "EMPTY"
          @empty << test
        else
          puts "OK"
          @test_count += 1
        end
        
      rescue EEtee::AssertionFailed => err
        @failures << err
        puts "FAILED"
        
      rescue EEtee::Error => err
        @errors << err
        puts "ERROR"
      end
      
      def report_results
        report_failures() unless @failures.empty?
        report_errors() unless @errors.empty?
        
        puts ""
        puts "#{@test_count} Tests / #{@assertion_count} Assertions"
        puts "#{@errors.size} Errors / #{@failures.size} failures"
      end

    private
      def iprint(msg)
        tmp = '  ' * @indent
        Kernel.print("#{tmp}#{msg}")
      end

      def iputs(msg)
        iprint("#{msg}\n")
      end
      
      def report_failures
        puts "\nFailures:"
        @failures.each do |f|
          puts "- #{f.test.label}: #{f.message}"
          dump_trace(f)
        end
      end
      
      def report_errors
        puts "\nErrors:"
        @errors.each do |err|
          puts "#{err.test.label}:"
          puts "    #{err.error.class} #{err.error}"
          dump_trace(err.error)
        end
      end
      
      def dump_trace(err, cleanup = true)
        lines = err.backtrace
        
        if cleanup
          lines.reject! do |line|
            line.include?('gems')
          end
        end
        
        lines.each do |line|
          puts "      #{line}"
        end

      end
      
    end
    
  end
end

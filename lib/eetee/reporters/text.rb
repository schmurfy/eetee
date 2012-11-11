module EEtee
  module Reporters
    
    class Text
      def initialize
        @errors = []
        @failures = []
        @indent = 0
        @assertions = 0
      end
      
      def increment_assertions
        @assertions += 1
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
        puts "OK"
        
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
        puts "#{@assertions} Assertions"
        puts "Completed with #{@errors.size} errors and #{@failures.size} failures"
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
      
      def dump_trace(err)
        err.backtrace.each do |line|
          puts "      #{line}"
        end

      end
      
    end
    
  end
end

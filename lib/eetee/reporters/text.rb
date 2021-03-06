module EEtee
  module Reporters
    
    ##
    # Basic text output.
    # 
    class Text < Reporter
      
      
      def around_context(ctx, &block)
        puts "" if @indent == 0
        iputs "# #{ctx.description}:"
        super
      end
      
      def around_test(test, &block)
        iprint "- #{test.label}... "
        case super
        when :empty   then puts "EMPTY"
        when :ok      then puts "OK"
        when :failed  then puts "FAILED"
        when :error   then puts "ERROR"
        end
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

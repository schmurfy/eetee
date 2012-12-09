# encoding: utf-8

require 'term/ansicolor'

module EEtee
  module Reporters
    
    ##
    # Advanced text output designed to be used in a open
    # console.
    # 
    class Console < Reporter
      Color = Term::ANSIColor
      
      def around_context(ctx, &block)
        puts "" if @indent == 0
        # iputs "# #{ctx.description}:"
        
        iputs "#{Color.underscore}#{ctx.description}#{Color.reset}"
        super
        
        puts "" if @indent == 0
      end
      
      def around_test(test, &block)
        iprint " ~ #{test.label}"
        
        ret = super
        
        # goto beginning of line
        print "\e[G\e[K"

        
        case ret
        when :empty   then iputs " #{Color.bold}#{Color.yellow}~#{Color.reset} #{test.label}"
        when :ok      then iputs " #{Color.green}✔#{Color.reset} #{test.label}"
        when :failed  then iputs " #{Color.red}✘#{Color.reset} #{test.label}"
        when :error   then iputs " #{Color.red}☁ #{test.label}#{Color.reset} [#{@errors[-1].class}]"
        end
      end
      
      def report_results
        report_failures() unless @failures.empty?
        report_errors() unless @errors.empty?
        report_empty() unless @empty.empty?
        
        puts ""
        puts "#{@test_count} Tests / #{@assertion_count} Assertions"
        puts "#{@errors.size} Errors / #{@failures.size} failures"
        if elapsed_time() == 0
          puts "Execution time: < 1s"
        else
          puts "Execution time: #{human_duration(elapsed_time)}"
        end
      end

    private
      
      def spaces(str = "  ")
        str * @indent
      end
      
      def iprint(msg)
        tmp = '  ' * @indent
        Kernel.print("#{tmp}#{msg}")
      end

      def iputs(msg)
        iprint("#{msg}\n")
      end
      
      def human_duration(secs)
        [[60, 'seconds'], [60, 'minutes'], [24, 'hours'], [1000, 'days']].map do |count, name|
          if secs > 0
            secs, n = secs.divmod(count)
            (n > 0) ? "#{n.to_i} #{name}" : nil
          end
        end.compact.reverse.join(' ')
      end
      
      def report_empty
        puts "\nEmpty tests:"
        @empty.each do |test|
          puts "- #{test.label}"
        end
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
            line.include?('.rbenv')
          end
        end
        
        lines.each do |line|
          puts "      #{line}"
        end

      end
      
    end
    
  end
end

require 'guard'
require 'guard/guard'

module Guard
  class Eetee < Guard
    ERROR_COLOR = [255, 56, 84].freeze
    EMPTY_COLOR = [0, 159, 193].freeze
    FAILURES_COLOR = [226, 117, 0].freeze
    SUCCESS_COLOR = [0, 219, 5].freeze
    FADE_DURATION = 200

    
    def self.template(*)
      File.read(
          File.expand_path('../Guardfile', __FILE__)
        )
    end

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      @reporter_class = options.delete(:reporter)
      @with_blink1 = options.delete(:blink1)      
      @last_run_spec = nil
      super
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      puts "Guard::EEtee started."
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
      if @with_blink1
        @blink1 = Blink1.new
        @blink1.open()
        @blink1.set_rgb(0,0,0)
        @blink1.close()
      end
      puts "Guard::EEtee stopped."
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
      
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_changes(paths)
      if (paths.size == 1)
        if !File.exists?(paths[0]) && @last_run_spec
          puts "spec not found: #{paths[0]}"
          puts "running last one."
          paths << @last_run_spec
        else
          @last_run_spec = paths[0]
        end
      end
      
      
      
      pid = Kernel.fork do
        require 'eetee'
        
        if @reporter_class
          EEtee.default_reporter_class = EEtee::Reporters.const_get(@reporter_class)
        end

        
        runner = EEtee::Runner.new
        runner.run_files(paths)
        runner.report_results()
        
        tests = runner.test_count
        failures = runner.failures.size + runner.errors.size
        
        focus_mode = runner.focus_mode
        
        if @with_blink1
          blink1 = Blink1.new
          blink1.open()
          
          if runner.errors.size > 0
            blink1.fade_to_rgb(FADE_DURATION, *ERROR_COLOR)
            
          elsif runner.failures.size > 0
            blink1.fade_to_rgb(FADE_DURATION, *FAILURES_COLOR)
            
          elsif runner.empty.size > 0
            blink1.fade_to_rgb(FADE_DURATION, *EMPTY_COLOR)
            
          else
            blink1.fade_to_rgb(FADE_DURATION, *SUCCESS_COLOR)
            
          end
          
          blink1.close()
        end

        
        if failures > 0
          Notifier.notify("Specs: #{failures} Failures (#{tests} tests) #{focus_mode ? '(focus)' : ''}",
              :image => :failed
            )
        else
          Notifier.notify("Specs: OK (#{tests} tests) #{focus_mode ? '(focus)' : ''}",
              :image => :success
            )
        end
      end
      
      Process.wait(pid)
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_removals(paths)
    end

  end
end

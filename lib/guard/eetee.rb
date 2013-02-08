require 'guard'
require 'guard/guard'

module Guard
  class Eetee < Guard
    
    def self.template(*)
      File.read(
          File.expand_path('../Guardfile', __FILE__)
        )
    end

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
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
      pid = Kernel.fork do
        require 'eetee'
        runner = EEtee::Runner.new
        runner.run_files(paths)
        runner.report_results()
        
        tests = runner.test_count
        failures = runner.failures.size + runner.errors.size
        
        focus_mode = runner.focus_mode
        
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

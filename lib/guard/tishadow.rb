require 'guard'
require 'guard/plugin'

module Guard
  class Tishadow < Plugin

    autoload :Server, 'guard/tishadow/server'
    autoload :Builder, 'guard/tishadow/builder'
    autoload :PeriodicCaller, 'guard/tishadow/periodic_caller'

    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even
    # if they are not in an active group!
    #
    # @param [Hash] options the Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file
    #   watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from
    #   a watcher
    #
    def initialize(options = {})
      @build_command = options.delete(:build_command)
      super
    end

    # Called once when Guard starts. Please override initialize method to
    # init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    # @!method start
    def start
      Server.supervise_as :tishadow_server, self, :run_on_connect
      Builder.supervise_as :tishadow_builder, :build_command => @build_command, :verbose => @verbose, :update => @update
      @builder = Celluloid::Actor[:tishadow_builder]
      @server = Celluloid::Actor[:tishadow_server]
      @server.async.start
    end

    def run_on_connect
      @builder.run
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard
    # quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    # @!method stop
    def stop
      @builder.terminate
      @server.terminate
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like
    # reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    # @!method reload
    def reload
      UI.info "Reloading Guard::TiShadow"
      stop
      start
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all
    # specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    # @!method run_all
    def run_all
      #run_on_changes(Watcher.match_files(self, Dir.glob("**/*.*")))
      @builder.notify(true)
    end

    # Default behaviour on file(s) changes that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_changes has failed
    # @return [Object] the task result
    #
    # @!method run_on_changes(paths)
    def run_on_changes(paths)
      @builder.notify
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    # @!method run_on_additions(paths)
    def run_on_additions(paths)
      @builder.notify
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    # @!method run_on_modifications(paths)
    def run_on_modifications(paths)
      @builder.notify
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    # @!method run_on_removals(paths)
    def run_on_removal(paths)
      @builder.notify
    end

  end
end

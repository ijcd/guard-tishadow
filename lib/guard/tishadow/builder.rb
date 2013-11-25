require 'celluloid'
require 'guard/tishadow/periodic_caller'

module Guard
  class Tishadow
    class Builder

      include Celluloid

      def initialize(options = {})
        @build_command = options.delete(:build_command) || "alloy compile --config platform=ios 2>&1 && tishadow close && tishadow run"
        @spec_command = options.delete(:spec_command) || "tishadow spec"
        @verbose = options.delete(:verbose)
        @update = options.delete(:update)
        @spec = options.delete(:spec)
        @update = true if @update.nil?
        @last_notice_at = nil
        @clock = nil
        @reload = false
      end

      def notify(reload = false)
        @reload ||= reload
        set_notified
        start_clock unless @clock
      end

      def start_clock
        @clock = PeriodCaller.new 1, :maybe_build, Celluloid.current_actor
      end

      def stop_clock
        @clock.terminate
        @clock = nil
      end

      def set_notified
        @last_notice_at = Time.now
      end

      def clear_notified
        @last_notice_at = nil
      end

      def time_to_build?
        (Time.now - @last_notice_at) > 1
      end

      def run
        shell_command(@build_command)
        UI.info("Alloy compile and tishadow run complete.")
      end

      def update
        shell_command("#{@build_command} --update")
        UI.info("Alloy compile and tishadow run --update complete.")
      end
      
      def spec
        shell_command(@spec_command)
        UI.info("Spec run complete.")
      end
            
      def run_or_update
        UI.info "Tishadow building at #{Time.now} with \"#{@build_command}\""
        if @reload || !@update
          @reload = false
          run
        else
          update
        end
        spec if @spec
      end

      # TODO: watch the process result and treat errors more carefully
      def maybe_build
        return unless @last_notice_at
        if time_to_build?
          UI.info "Tishadow building at #{Time.now} with \"#{@build_command}\""
          run_or_update
          clear_notified
          stop_clock
        end
      end
      
      def shell_command(cmd)
        UI.info(cmd)
        format_result(`#{cmd}`)
      end
      
      def format_result(result)
        if @verbose
          UI.info(result)
        else
          UI.error(result.split("\n").grep(/error/i).join("\n"))
        end
      end
      
    end
  end
end

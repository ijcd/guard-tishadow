require 'celluloid'
require 'guard/tishadow/periodic_caller'

module Guard
  class Tishadow
    class Builder

      include Celluloid

      def initialize(options = {})
        @build_command = options.delete(:build_command) || "alloy compile --config platform=ios 2>&1 && tishadow run"
        @last_notice_at = nil
        @clock = nil
      end

      def notify
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
        UI.info `#{@build_command}`
      end

      def update
        UI.info `#{@build_command} --update`
      end

      # TODO: watch the process result and treat errors more carefully
      def maybe_build
        return unless @last_notice_at
        if time_to_build?
          UI.info "Tishadow building at #{Time.now} with \"#{@build_command}\""
          update
          clear_notified
          stop_clock
        end
      end

    end
  end
end

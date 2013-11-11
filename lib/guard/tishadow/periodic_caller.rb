require 'celluloid'

module Guard
  class Tishadow
    class PeriodCaller

      include Celluloid

      def initialize(interval, signal, recipient)
        @interval = interval
        @signal = signal
        @recipient = recipient
        self.async.start
      end

      def start
        loop do
          sleep @interval
          @recipient.send(@signal)
        end
      end

    end
  end
end

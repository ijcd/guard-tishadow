require 'celluloid'
require 'childprocess'

module Guard
  class Tishadow
    class Server

      include Celluloid

      def initialize(who_to_notify, how_to_notify)
        @who_to_notify = who_to_notify
        @how_to_notify = how_to_notify
      end

      def start
        UI.info 'Starting tishadow server'

        ChildProcess.posix_spawn = true
        @proc = ChildProcess.build("tishadow", "server")
        stdout, stdout_writer = IO.pipe
        stderr, stderr_writer = IO.pipe
        stdout.sync = true
        stderr.sync = true
        @proc.io.stdout = stdout_writer
        @proc.io.stderr = stderr_writer
        @proc.start

        # read stdout
        Thread.new do
          UI.info "reading stdout"
          stdout.each do |line|
            # if line =~ %r{\[(\S+), (\S+), (\S+)\] Connected}
            #   UI.info "Connected #{$1}, #{$2}, #{$3} --> sending notification to #{@who_to_notify}#@#{@how_to_notify}"
            #   @who_to_notify.send @how_to_notify if @who_to_notify && @how_to_notify
            # end
            UI.info "TISHADOW stdout: #{line}"
          end
        end

        # read stderr
        Thread.new do
          stderr.each_line do |line|
            UI.error "TISHADOW stderr: #{line}"
          end
        end

        # wait on the process for cleanup
        Thread.new do
          begin
            @proc.wait
            UI.info "*********** TiShadow Server Terminated *************"
            self.terminate
          ensure
            @proc.stop if @proc
          end
        end

        UI.info 'Started tishadow server'

        at_exit do
          stop
        end

        #loop { sleep 1 }
      end

      def stop
        return unless @proc && @proc.alive?
        @proc.stop
        # begin
        #   @proc.poll_for_exit(10)
        # rescue ChildProcess::TimeoutError
        #   @proc.stop # tries increasingly harsher methods to kill the process.
        # end
        UI.info "*********** TiShadow Server Stopped ********************"
      end

      finalizer do
        UI.info "*********** TiShadow Server Finalizing ********************"
        self.async.stop
      end

    end
  end
end

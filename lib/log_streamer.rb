module LogStreamer
  module ClassMethods

    def stream_logs(url, timeout=20)
      Timeout::timeout(timeout) do
        EventMachine.run  do
          http = EventMachine::HttpRequest.new(url,
                        keepalive: true,
                        connection_timeout: 0,
                        inactivity_timeout: 0).get
          buffer = ""
          http.stream do |chunk|
            buffer << chunk
            while line = buffer.slice!(/.+\n/)
              yield line
            end
          end
        end
      end
    end

  end

  module InstanceMethods
  end

  def self.included(base)
    base.extend         ClassMethods
    base.send :include, InstanceMethods
  end
end
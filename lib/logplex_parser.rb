require 'excon'

class LogplexParser

  def initialize(api_key, app_name)
    @api_key, @app_name = api_key, app_name
  end

  def parse(response)
    begin
      stream_logs logplex_url, 600 do |line|
        timestamp, _, data = line.split(/\s+/, 3)
        if data
          next unless data.match /.*at=info method=GET.*/
          time = Time.iso8601(timestamp) rescue nil
          next unless time
          _, get_url, host, remote_ip = data.match(/at=info method=GET path=(.*) host=(.*) fwd="(.*)".*/).to_a
          response.call({
              :path => get_url,
              :host => host,
              :remote_ip => remote_ip
            })
        end
      end
    rescue
      # exit
    end
  end

  private

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

  def api
    @api ||= Heroku::API.new(api_key: @api_key)
  end

  def logplex_url
    @logplex_url ||= api.get_logs(@app_name, {tail: 1, num: 1500}).body
  end
end
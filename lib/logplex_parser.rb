require 'excon'

module HerokuLogwatch
  class LogplexParser

    def initialize(api_key, app_name)
      @api_key, @app_name = api_key, app_name
    end

    def parse(&block)
      begin
        stream_logs logplex_url, 600 do |line|
          timestamp, _, data = line.split(/\s+/, 3)
          next unless data
          time = Time.iso8601(timestamp) rescue nil
          next unless time
          _, get_url, host, remote_ip = data.match(/at=info method=GET path=(.+) host=(.*) fwd="(.*)"/).to_a
          yield {
            path: get_url,
            host: host,
            remote_ip: remote_ip
          }
        end
      rescue
        # exit
      end
    end

    private

    def api
      @api ||= Heroku::API.new(api_key: @api_key)
    end

    def logplex_url
      @logplex_url ||= api.get_logs(@app_name, {tail: 1, num: 1500}).body
    end
  end
end
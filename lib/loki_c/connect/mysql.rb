# frozen_string_literal: true

module LokiC
  module Connect
    class Mysql # :nodoc:
      def self.on(host, database)
        Mysql2::Client.new(
          host: host,
          database: database,
          username: Rails.application.credentials.mysql[:user],
          password: Rails.application.credentials.mysql[:password],
          connect_timeout: 180,
          reconnect: true,
          encoding: 'utf8'
        )
      end
    end
  end
end

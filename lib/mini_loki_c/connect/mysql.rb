# frozen_string_literal: true

require_relative '../../../config/passwords'

module MiniLokiC
  module Connect
    class Mysql # :nodoc:
      def self.on(host, database, username = nil, password = nil)
        if username.nil? && password.nil?
          username = Mysql_user[:username]
          password = Mysql_user[:password]
        end
        Mysql2::Client.new(
          host: host,
          database: database,
          username: username,
          password: password,
          connect_timeout: 180,
          reconnect: true,
          encoding: 'utf8'
        )
      end
    end
  end
end

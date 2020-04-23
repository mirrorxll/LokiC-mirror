# frozen_string_literal: true

module MiniLokiC
  module Connect
    # Mysql connection
    module Mysql
      def self.on(host, database, username = nil, password = nil)
        if username.nil? && password.nil?
          username = MYSQL_USER[:name]
          password = MYSQL_USER[:password]
        end

        Mysql2::Client.new(
          host: host, database: database,
          username: username, password: password,
          connect_timeout: 180, reconnect: true,
          encoding: 'utf8'
        )
      end
    end
  end
end

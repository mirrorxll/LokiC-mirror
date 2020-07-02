# frozen_string_literal: true

module MiniLokiC
  module Connect
    # Mysql connection
    module Mysql
      def self.on(host, database, username = nil, password = nil)
        username ||= MiniLokiC.mysql_regular_user
        password ||= MiniLokiC.mysql_regular_password

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

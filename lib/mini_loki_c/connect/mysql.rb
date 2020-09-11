# frozen_string_literal: true

module MiniLokiC
  module Connect
    # Mysql connection
    module Mysql
      def self.on(host, database, username = nil, password = nil)
        username ||= MiniLokiC.mysql_regular_user
        password ||= MiniLokiC.mysql_regular_password
        fallen = 0

        begin
          Mysql2::Client.new(
            host: host, database: database,
            username: username, password: password,
            connect_timeout: 180, reconnect: true,
            encoding: 'utf8'
          )
        rescue Mysql2::Error => e
          raise Mysql2::Error, e if fallen > 3

          fallen += 1
          sleep(3)
          retry
        end
      end
    end
  end
end

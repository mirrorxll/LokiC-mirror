# frozen_string_literal: true

module MiniLokiC
  module Connect
    # Mysql connection
    module Mysql
      def self.on(host, database = nil, username = nil, password = nil)
        username ||= MiniLokiC.mysql_regular_user
        password ||= MiniLokiC.mysql_regular_password
        fallen = 0

        begin
          Mysql2::Client.new(
            host: host, database: database,
            username: username, password: password,
            connect_timeout: 180, reconnect: true
          )
        rescue Mysql2::Error => e
          raise Mysql2::Error, e if fallen > 3

          fallen += 1
          sleep(3)
          retry
        end
      end

      def self.exec_query(host, database, query, symbolize = false)
        conn = on(host, database)
        query_result = conn.query(query, symbolize_keys: symbolize)
        conn.close

        query_result
      end
    end
  end
end

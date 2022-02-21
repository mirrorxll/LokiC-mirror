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
          db = Mysql2::Client.new(
            host: host, database: database,
            username: username, password: password,
            connect_timeout: 180, reconnect: true
          )
          db.query('SET NAMES utf8mb4 COLLATE utf8mb4_general_ci') if UPDATED_MB4_BASES.include?(db.query_options.slice(:host, :database))
          db
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

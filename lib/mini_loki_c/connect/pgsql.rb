# frozen_string_literal: true

module MiniLokiC
  module Connect
    # establishing connect to PGsql database
    module Pgsql
      def self.on(host, database = nil, username = nil, password = nil)
        unless username && password
          username = MiniLokiC.postgresql_user
          password = MiniLokiC.postgresql_password
        end
        fallen = 0
        retries_sleep_time = { 1 => 1.fact, 2 => 2.fact, 3 => 3.fact, 4 => 4.fact, 5 => 5.fact }

        begin
          PG.connect(host: host, dbname: database, user: username, password: password)
        rescue PG::Error => e
          fallen += 1
          raise PG::Error, e if fallen > 5

          sleep(retries_sleep_time[fallen])
          retry
        end
      end

      def self.exec_query(host, database, query, symbolize_keys = false)
        conn = on(host, database)
        query_result = conn.query(query, symbolize_keys: symbolize_keys)
        conn.close

        query_result
      end
    end
  end
end

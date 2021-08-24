# frozen_string_literal: true

module MiniLokiC
  module Population
    # module generate SQL queries
    module SQL
      module_function

      def insert_on_duplicate_key(table, data = {}, route = nil)
        keys = []
        values = []
        updates = []

        data.map do |(k, val)|
          key = "`#{k}`"
          value = prepare_value(val, route)

          keys << key
          values << value
          updates << "#{key} = #{value}"
        end

        "INSERT INTO `#{table}` (#{keys.join(', ')}) "\
        "VALUES (#{values.join(', ')}) "\
        "ON DUPLICATE KEY UPDATE #{updates.join(', ')};"
      end

      def insert_ignore(table, data = {}, route = nil)
        keys = []
        values = []

        data.map do |(k, val)|
          key = "`#{k}`"
          value = prepare_value(val, route)

          keys << key
          values << value
        end

        "INSERT IGNORE INTO `#{table}` (#{keys.join(', ')}) "\
        "VALUES (#{values.join(', ')});"
      end

      def prepare_value(val, route)
        raw_val =
          case val
          when Date, Time, BigDecimal
            val.to_s
          when TrueClass, FalseClass
            val ? 1 : 0
          when String
            val
          else
            val.to_json
          end

        client = route || Mysql2::Client
        val.nil? ? 'NULL' : "'#{client.escape(raw_val.to_s)}'"
      end
    end
  end
end

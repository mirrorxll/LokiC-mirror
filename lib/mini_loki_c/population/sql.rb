# frozen_string_literal: true

module MiniLokiC
  module Population
    # module generate SQL queries
    module SQL
      module_function

      def insert_on_duplicate_key(table, data = {})
        keys = []
        values = []
        updates = []

        data.map do |(k, val)|
          key = "`#{k}`"
          value = prepare_value(val)

          keys << key
          values << value
          updates << "#{key} = #{value}"
        end

        "INSERT INTO `#{table}` (#{keys.join(', ')}) "\
        "VALUES (#{values.join(', ')}) "\
        "ON DUPLICATE KEY UPDATE #{updates.join(', ')};"
      end

      def insert_ignore(table, data = {})
        keys = []
        values = []

        data.map do |(k, val)|
          key = "`#{k}`"
          value = prepare_value(val)

          keys << key
          values << value
        end

        "INSERT IGNORE INTO `#{table}` (#{keys.join(', ')}) "\
        "VALUES (#{values.join(', ')});"
      end

      def prepare_value(val)
        raw_val =
          if val.is_a?(Date) || val.is_a?(Time)
            val.to_s
          elsif val.is_a?(String)
            val
          elsif val.is_a?(TrueClass)
            1
          elsif val.is_a?(FalseClass)
            0
          else
            val.to_json
          end

        val.nil? ? 'NULL' : "'#{Mysql2::Client.escape(raw_val.to_s)}'"
      end
    end
  end
end

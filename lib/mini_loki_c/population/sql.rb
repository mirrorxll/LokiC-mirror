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
        case val
        when String
          val.dump
        when TrueClass
          1
        when FalseClass
          0
        when NilClass
          'NULL'
        when Array, Hash
          val.to_json.dump
        else
          val.to_json
        end
      end
    end
  end
end

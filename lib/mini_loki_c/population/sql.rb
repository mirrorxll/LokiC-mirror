# frozen_string_literal: true

module MiniLokiC
  module Population
    # module generate SQL queries
    module SQL
      module_function

      def insert_on_duplicate_key(table, options = {})
        keys = []
        values = []
        updates = []

        options.map do |(k, val)|
          key = "`#{k}`"
          value =
            case val.class
            when TrueClass, FalseClass
              val ? 1 : 0
            when String
              val.dump
            else
              val.to_json.dump
            end

          keys << key
          values << value
          updates << "#{key} = #{value}"
        end

        "INSERT INTO `#{table}` (#{keys.join(', ')}) "\
        "VALUES (#{values.join(', ')}) "\
        "ON DUPLICATE KEY UPDATE #{updates.join(', ')}"
      end
    end
  end
end

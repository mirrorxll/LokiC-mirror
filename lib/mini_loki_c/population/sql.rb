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

        options.map do |(k, v)|
          boolean = [TrueClass, FalseClass].any? { |klass| v.is_a?(klass) }

          key = "`#{k}`"
          value =
            if boolean
              v ? 1 : 0
            else
              v ? v.to_json : 'NULL'
            end

          keys << key
          values << value
          updates << "#{key} = #{boolean ? value : value.dump}"
        end

        "INSERT INTO `#{table}` (#{keys.join(', ')}) "\
        "VALUES (#{values.join(', ')}) "\
        "ON DUPLICATE KEY UPDATE #{updates.join(', ')}"
      end
    end
  end
end

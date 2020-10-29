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
            case val
            when String
              "'#{Mysql2::Client.escape(val)}'"
            when TrueClass
              1
            when FalseClass
              0
            when NilClass
              'NULL'
            when Array, Hash
              "'#{Mysql2::Client.escape(val.to_json)}'"
            else
              val.to_json
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

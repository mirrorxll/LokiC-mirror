# frozen_string_literal: true

module LokiC
  module StagingTable
    class Columns # :nodoc:
      HIDDEN_COLUMNS = %w[
        id story_created client_id client_name
        publication_id publication_name organization_id
        publish_on created_at updated_at
      ].freeze

      def self.dropped(curr_col, mod_col)
        current = curr_col.keys
        modify = mod_col.keys

        current.each_with_object([]) do |c_hex, obj|
          obj << c_hex unless modify.include?(c_hex)
        end
      end

      def self.added(curr_col, mod_col)
        current = curr_col.keys
        modify = mod_col.keys

        modify.each_with_object([]) do |m_hex, obj|
          obj << m_hex unless current.include?(m_hex)
        end
      end

      def self.changed(curr_col, mod_col)
        curr_col.keys.each_with_object([]) do |hex, obj|
          current = curr_col[hex]
          modify = mod_col[hex]
          next if current.eql?(modify)

          upd = {}
          upd[:old_name] = current[:name]
          upd[:new_name] = modify[:name]
          upd[:type] = modify[:type]
          upd[:opts] = modify[:opts]

          obj << upd
        end
      end

      def self.frontend_transform(columns)
        return {} if columns.empty?

        columns.each_with_object({}) do |(id, column), hash|
          column['opts'] ||= {}

          hash[id.to_sym] = column.deep_symbolize_keys
        end
      end

      def self.backend_transform(columns)
        columns.reject! { |col| HIDDEN_COLUMNS.include?(col.name) }
        return {} if columns.empty?

        columns.each_with_object({}) do |col, hash|
          column = ar_to_hash(col)

          hash[SecureRandom.hex(3).to_sym] = column
        end
      end

      def self.ar_to_hash(column)
        {
          name: column.name,
          type: column.type,
          opts: {
            limit: column.limit,
            precision: column.precision,
            scale: column.scale
          }
        }
      end
    end
  end
end

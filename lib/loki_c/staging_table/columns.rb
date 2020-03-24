# frozen_string_literal: true

module LokiC
  module StagingTable
    class Columns # :nodoc:
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
        a = curr_col.keys.each_with_object([]) do |hex, obj|
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
        return [] if columns.empty?

        columns.each_with_object({}) do |(id, column), hash|
          column['opts'] ||= {}

          hash[id.to_sym] = column.deep_symbolize_keys
        end
      end

      def self.backend_transform(columns)
        return [] if columns.empty?

        columns.each_with_object({}) do |col, hash|
          type_opts = sql_to_ar(col[1])

          hash[SecureRandom.hex(3).to_sym] = { name: col[0] }.merge(type_opts)
        end
      end

      def self.sql_to_ar(type)
        tp, opt = type.split(/[()]/)

        case tp
        when 'tinyint'
          { type: 'boolean', opts: {} }
        when 'int'
          { type: 'integer', opts: {} }
        when 'decimal'
          pr, scl = opt.split(',')
          { type: 'decimal', opts: { precision: pr, scale: scl } }
        when 'varchar'
          { type: 'string', opts: { limit: opt } }
        else
          { type: tp, opts: {} }
        end
      end
    end
  end
end

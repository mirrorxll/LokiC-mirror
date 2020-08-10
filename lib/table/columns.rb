# frozen_string_literal: true

# NATIVE_DATABASE_TYPES = {
#   primary_key: "bigint auto_increment PRIMARY KEY",
#   string:      { name: "varchar", limit: 255 },
#   text:        { name: "text" },
#   integer:     { name: "int", limit: 4 },
#   float:       { name: "float", limit: 24 },
#   decimal:     { name: "decimal" },
#   datetime:    { name: "datetime" },
#   timestamp:   { name: "timestamp" },
#   time:        { name: "time" },
#   date:        { name: "date" },
#   boolean:     { name: "tinyint", limit: 1 }
# }

module Table
  module Columns # :nodoc:
    HIDDEN_COLUMNS = %w[
      id source_table_id source_id story_created client_id
      client_name publication_id publication_name organization_ids
      publish_on created_at updated_at iter_id time_frame
    ].freeze

    def columns(t_name)
      columns = loki_story_creator { a_r_m.columns(t_name) }
      columns_transform(columns, :back)
    end

    def modify_columns(t_name, cur_col, mod_col)
      loki_story_creator do
        if a_r_m.index_name_exists?(t_name, :story_per_publication)
          a_r_m.remove_index(t_name, name: :story_per_publication)
        end

        dropped(cur_col, mod_col).each do |hex|
          col = cur_col.delete(hex)
          a_r_m.remove_column(t_name, col[:name])
        end

        added(cur_col, mod_col).each do |hex|
          col = mod_col.delete(hex)
          a_r_m.add_column(t_name, col[:name], col[:type], **col[:options])
        end

        changed(cur_col, mod_col).each do |upd|
          a_r_m.rename_column(t_name, upd[:old_name], upd[:new_name]) if upd[:old_name] != upd[:new_name]
          a_r_m.change_column(t_name, upd[:new_name], upd[:type], **upd[:options])
        end
      end

      nil
    end

    def dropped(curr_col, mod_col)
      current = curr_col.keys
      modify = mod_col.keys

      current.each_with_object([]) do |c_hex, obj|
        obj << c_hex unless modify.include?(c_hex)
      end
    end

    def added(curr_col, mod_col)
      current = curr_col.keys
      modify = mod_col.keys

      modify.each_with_object([]) do |m_hex, obj|
        obj << m_hex unless current.include?(m_hex)
      end
    end

    def changed(curr_col, mod_col)
      curr_col.keys.each_with_object([]) do |hex, obj|
        current = curr_col[hex]
        modify = mod_col[hex]
        next if current.eql?(modify)

        upd = {}
        upd[:old_name] = current[:name]
        upd[:new_name] = modify[:name]
        upd[:type] = modify[:type]
        upd[:options] = modify[:options]

        obj << upd
      end
    end

    def columns_transform(columns, place)
      case place
      when :front
        frontend_transform(columns)
      when :back
        backend_transform(columns)
      when :samples
        transform_for_samples(columns)
      end
    end

    private

    def backend_transform(columns)
      columns.reject! { |col| HIDDEN_COLUMNS.include?(col.name) }
      return {} if columns.empty?

      columns.each_with_object({}) do |col, hash|
        hash[SecureRandom.hex(3).to_sym] = ar_to_hash(col)
      end
    end

    def ar_to_hash(column)
      {
        name: column.name,
        type: column.type,
        options: {
          limit: column.limit,
          scale: column.scale,
          precision: column.precision
        }
      }
    end

    def frontend_transform(columns)
      return {} if columns.empty?

      params_to_hash = {}
      columns.each do |id, column|
        id_sym = id.to_sym
        params_to_hash[id_sym] = {}
        params_to_hash[id_sym][:name] = column[:name]
        params_to_hash[id_sym][:type] = column[:type].to_sym
        params_to_hash[id_sym][:options] = nilable_if_empty(column[:options])
      end

      params_to_hash
    end

    def nilable_if_empty(options)
      return { limit: nil, scale: nil, precision: nil } if options.nil?

      options_to_hash = {}
      options_to_hash[:limit] = options[:limit].present? ? options[:limit] : nil
      options_to_hash[:precision] = options[:precision].present? ? options[:precision] : nil
      options_to_hash[:scale] = options[:scale].present? ? options[:scale] : nil
      options_to_hash
    end

    def transform_for_samples(columns)
      columns.select! { |_key, value| value.eql?('1') }
      columns.keys.map(&:to_sym)
    end
  end
end

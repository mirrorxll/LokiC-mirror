# frozen_string_literal: true

module Table
  module Columns # :nodoc:
    HIDDEN_COLUMNS = %w[
      id story_created client_id client_name
      publication_id publication_name organization_ids
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
          a_r_m.add_column(t_name, col[:name], col[:type], col[:opts])
        end

        changed(cur_col, mod_col).each do |upd|
          if upd[:old_name] != upd[:new_name]
            a_r_m.rename_column(t_name, upd[:old_name], upd[:new_name])
          end

          a_r_m.change_column(t_name, upd[:new_name], upd[:type], upd[:opts])
        end
      end
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
        upd[:opts] = modify[:opts]

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
      else
        'Raise to do'
      end
    end

    private

    def backend_transform(columns)
      columns.reject! { |col| HIDDEN_COLUMNS.include?(col.name) }
      return {} if columns.empty?

      columns.each_with_object({}) do |col, hash|
        column = ar_to_hash(col)

        hash[SecureRandom.hex(3).to_sym] = column
      end
    end

    def ar_to_hash(column)
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

    def frontend_transform(columns)
      return {} if columns.empty?

      columns.each_with_object({}) do |(id, column), hash|
        column['opts'] ||= {}
        column['opts'] = default_if_empty(column['opts'])

        hash[id.to_sym] = column.deep_symbolize_keys
      end
    end

    def default_if_empty(options)
      return options if options.empty?

      if options.key?('limit') && options['limit'].empty?
        options['limit'] = '255'
      end

      if options.key?('scale') && options['scale'].empty?
        options['scale'] = '0'
      end

      if options.key?('precision') && options['precision'].empty?
        options['precision'] = '10'
      end

      options
    end

    def transform_for_samples(columns)
      columns.select! { |_key, value| value.eql?('1') }
      columns.keys.map(&:to_sym)
    end
  end
end

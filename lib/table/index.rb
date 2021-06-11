# frozen_string_literal: true

module Table
  module Index
    HIDDEN_COLUMNS = %w[
      client_id client_name
      publication_id publication_name time_frame
    ].freeze

    def index(t_name)
      t_name = schema_table(t_name)
      indexes = loki_story_creator { |conn| conn.indexes(t_name) }
      index_columns = indexes.find { |i| i.name.eql?('story_per_publication') }
      index_transform(index_columns)
    end

    def uniq_index_not_exists?(t_name)
      t_name = schema_table(t_name)
      !loki_story_creator { |conn| conn.index_name_exists?(t_name, :story_per_publication) }
    end

    def add_uniq_index(t_name, columns)
      t_name = schema_table(t_name)
      columns = columns.map { |_id, c| c[:name] }
      columns = ['client_id', 'publication_id', 'time_frame', columns].flatten
      loki_story_creator { |conn| conn.add_index(t_name, columns, unique: true, name: :story_per_publication) }

      nil
    end

    def drop_uniq_index(t_name)
      loki_story_creator { |conn| conn.remove_index(t_name, name: :story_per_publication) }

      nil
    end

    def index_transform(index_columns)
      return [] if index_columns.nil?

      index_columns.columns.reject! { |col| HIDDEN_COLUMNS.include?(col) }
    end
  end
end

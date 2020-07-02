# frozen_string_literal: true

module Table
  module Index
    HIDDEN_COLUMNS = %w[
      client_id client_name
      publication_id publication_name
    ].freeze

    def index_transform(index_columns)
      return [] if index_columns.nil?

      index_columns.columns.reject! { |col| HIDDEN_COLUMNS.include?(col) }
    end
  end
end

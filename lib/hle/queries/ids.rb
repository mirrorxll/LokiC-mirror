# frozen_string_literal: true

module Hle
  module Queries
    module Ids # :nodoc:
      def self.from_raw(columns)
        columns.keys.map { |key| key.to_s.split('_').last }.uniq
      end

      def self.from_pure(columns)
        columns.map { |c| c.symbolize_keys[:id] }
      end
    end
  end
end

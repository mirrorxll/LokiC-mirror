# frozen_string_literal: true

module Samples
  module AutoFeedbackGenerator
    module Lists
      private

      def list_states
        @db02.query('select * from feedback_tool__states limit 1, 55;')
      end

      def list_contractions
        @db02.query('select * from feedback_tool__contractions;')
      end

      def list_address_abbr
        @db02.query('select * from feedback_tool__address_abbreviations;')
      end
    end
  end
end

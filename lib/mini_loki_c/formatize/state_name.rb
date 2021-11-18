# frozen_string_literal: true

module MiniLokiC
  module Formatize
    module StateName
      module_function

      include Constants

      def convert_name(state)
        if STATES_SHORT_LONG.key?(state)
          STATES_SHORT_LONG[state]
        elsif STATES_SHORT_LONG.value?(state)
          STATES_SHORT_LONG.key(state)
        else
          ''
        end
      end
    end
  end
end

# frozen_string_literal: true

module MiniLokiC
  module Formatize
    module StateName
      module_function

      include Constants

      def convert_name(state)
        if STATES_SHORT.any?(Regexp.new(state, true))
          STATES_SHORT_LONG[state]
        elsif STATES_LONG.any?(Regexp.new(state, true))
          STATES_SHORT_LONG.key(state)
        else
          ''
        end
      end

      def to_short(stt)
        if STATES_SHORT.any?(Regexp.new(stt, true))
          stt
        elsif STATES_LONG.any?(Regexp.new(stt, true))
          STATES_SHORT_LONG.key(stt)
        else
          ''
        end
      end

      def to_long(state)
        if STATES_LONG.any?(Regexp.new(state, true))
          state
        elsif STATES_SHORT.any?(Regexp.new(state, true))
          STATES_SHORT_LONG[state]
        else
          ''
        end
      end

      def list_to_short(list = STATES_LONG)
        list.map do |state|
          to_short(state)
        end
      end

      def list_to_long(list = STATES_SHORT)
        list.map do |st|
          to_long(st)
        end
      end
    end
  end
end

# frozen_string_literal: true

module MiniLokiC
  module Formatize
    # module for money
    module Money
      module_function

      def add_commas(value)
        if value.negative?
          "-$#{Formatize::Numbers.add_commas(value.abs)}"
        else
          "$#{Formatize::Numbers.add_commas(value)}"
        end
      end

      def add_commas_with_decimals(value)
        if value.negative?
          "-$#{Formatize::Numbers.add_commas_with_decimals(value.abs)}"
        else
          "$#{Formatize::Numbers.add_commas_with_decimals(value)}"
        end
      end

      def huge_money_to_text(value)
        if value.negative?
          "-$#{Formatize::Numbers.huge_number_to_text(value)}"
        else
          "$#{Formatize::Numbers.huge_number_to_text(value)}"
        end
      end
    end
  end
end

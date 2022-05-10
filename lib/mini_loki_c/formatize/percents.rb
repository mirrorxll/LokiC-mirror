# frozen_string_literal: true

module MiniLokiC
  module Formatize
    # module for percents
    module Percents
      module_function

      def calculate_percent(curr, prev, sign = false)
        res = ((curr.to_f - prev) / prev) * 100
        res = sign ? res : res.abs
        format_percentage(res)
      end

      def format_percentage(value, symbol = false)
        suffix =
          case symbol
          when false; ''
          when true; '%'
          else " #{symbol}"
          end
        "#{Formatize::Numbers.add_commas(value.to_f.round(1))}#{suffix}"
      end
    end
  end
end

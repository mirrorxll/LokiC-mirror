# frozen_string_literal: true

module MiniLokiC
  module Population
    module Frame
      def self.[](period, date)
        date = Date.parse(date)

        case period
        when :daily then      "d:#{date.yday}:#{date.year}"
        when :weekly then     "w:#{date.cweek}:#{date.cwyear}"
        when :monthly then    "m:#{date.month}:#{date.year}"
        when :quarterly then  "q:#{(date.month / 3.0).ceil}:#{date.year}"
        when :biannually then "b:#{date.month < 7 ? 1 : 2}:#{date.year}"
        when :annually then   date.year.to_s
        when :biennially then "b:#{date.year - 1}-#{date.year}"
        else raise ArgumentError, 'The passed frame is not correct.'
        end
      end
    end
  end
end

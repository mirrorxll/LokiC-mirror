# frozen_string_literal: true

module MiniLokiC
  module Population
    module Frame
      def self.[](period, date)
        date = Date.parse(date)

        case period
        when :daily then      "d:#{date.yday}:#{date.year}"
        when :weekly then     "w:#{date.cweek}:#{date.year}"
        when :monthly then    "m:#{date.month}:#{date.year}"
        when :quarterly then  "q:#{(date.month / 3.0).ceil}:#{date.year}"
        when :biannually then "b:#{date.month < 7 ? 1 : 2}:#{date.year}"
        when :annually then   date.year.to_s
        else raise ArgumentError, 'The passed frame is not correct.'
        end
      end
    end
  end
end

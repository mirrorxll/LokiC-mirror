# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      module FromCode # :nodoc:
        module_function

        def run_from_code(samples, options)
          return if samples.empty?

          if options[:start_date].present?
            options[:previous_date] = 1
            options[:extra_args] = options[:where] if options.has_key?(:where)
            Base.old_scheduler(samples, options)
            return if samples.where(published_at: nil).empty?
          end

          Backdate.backdate_scheduler(samples, backdate_options(options[:backdate])) if options[:backdate]
        end

        def backdate_options(options)
          options = options.is_a?(Array) ? options : [options]
          options.each do |option|
            option[:time_frame] = '' unless option.has_key?(:time_frame)
            option[:where] = '' unless option.has_key?(:where)
          end
        end
      end
    end
  end
end

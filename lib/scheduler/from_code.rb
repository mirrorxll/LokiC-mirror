# frozen_string_literal: true

module Scheduler
  module FromCode # :nodoc:
    def self.run_from_code(samples, options)
      Base.old_scheduler(samples, options)
      return if samples.where(published_at: nil).empty?

      Backdate.backdate_scheduler(samples, backdate_params(options[:backdate])) if options[:backdate]
    end

    def self.backdate_params(params)
      return { params => '' } if params.class == String

      puts params.count
      backdate_params = {}
      params.each do |elem|
        puts elem
        puts backdate_params
        puts '2222'
        elem.class == String ? backdate_params[elem.to_s] = '' : backdate_params[elem.first[0].to_s] = elem.first[1]
      end
      puts '1111111'
      puts backdate_params
      backdate_params
    end
  end
end

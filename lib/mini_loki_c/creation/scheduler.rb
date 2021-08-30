# frozen_string_literal: true

require_relative '../../mini_loki_c/connect/mysql.rb'
require_relative 'scheduler/base.rb'
require_relative 'scheduler/backdate.rb'
require_relative 'scheduler/auto.rb'

module MiniLokiC
  module Creation
    module Scheduler
      include Base
      include Backdate
      include Auto

      def self.run(staging_table, options, scheduling_rules)
        return if options[:sampled] || !Table.all_stories_created_by_iteration?(staging_table, options[:publication_ids])

        options[:iteration].update!(schedule: false)
        StoryTypes::SchedulerJob.perform_now(options[:iteration], :run_from_code, scheduling_rules)
      end
    end
  end
end

# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      include Base
      include Backdate
      include Auto
      include PressRelease

      def self.run(staging_table, options, scheduling_rules)
        if options[:sampled] || !Table.all_stories_created_by_iteration?(staging_table, options[:publication_ids])
          return
        end

        options[:iteration].update!(schedule: false)
        StoryTypes::Iterations::SchedulerTask.new.perform(options[:iteration].id, :"run-from-code", { params: scheduling_rules, cron: true })
      end

      def self.run_press_release(staging_table, options)
        if options[:sampled] || !Table.all_stories_created_by_iteration?(staging_table, options[:publication_ids])
          return
        end

        options[:iteration].update!(schedule: false)
        StoryTypes::Iterations::SchedulerTask.new.perform(options[:iteration].id, :press_release, { cron: true })
      end
    end
  end
end

# frozen_string_literal: true

module StoryTypes
  module Iterations
    class SetNextExportDateTask < StoryTypesTask
      def perform(story_type_id)
        story_type  = StoryType.find(story_type_id)
        last_export = story_type.last_export
        frequency   = story_type.frequency&.name

        if last_export && frequency
          next_date   = case frequency
                        when 'daily'
                          last_export + 1.day
                        when 'weekly'
                          last_export + 1.week
                        when 'monthly'
                          last_export + 1.month
                        when 'quarterly'
                          last_export + 3.month
                        when 'biannually'
                          last_export + 6.month
                        when 'annually'
                          last_export + 12.month
                        when 'biennially'
                          last_export + 24.month
                        end
        end

        story_type.update!(next_export: next_date)
      end
    end
  end
end

# frozen_string_literal: true

module StoryTypes
  module ShowHelper
    def story_types_blocked_item?
      true unless [@story_type.staging_table_attached.eql?(false), @story_type.staging_table&.indices_modifying.eql?(true),
                   @story_type.staging_table&.columns_modifying.eql?(true), @iteration.population.eql?(false),
                   @iteration.samples.eql?(false), @iteration.creation.eql?(false),
                   @iteration.purge_creation.eql?(true), @iteration.schedule.eql?(false),
                   @iteration.export.eql?(false), @iteration.purge_export.eql?(true)].any?
    end

    def purge_export_availability
      stories = @iteration.stories.where(backdated: false)
      if @story_type.iteration.eql?(@iteration) && @story_type.staging_table && @iteration.creation && @iteration.schedule
        if @iteration.export.eql?(true) && !@iteration.purge_export.eql?(true)
          story = stories.where.not(published_at: nil).order(:published_at).first
          true unless story && story.published_at <= Time.now
        elsif @iteration.export.eql?(true) && @iteration.purge_export.eql?(true)
          false
        else
          exported = stories.where.not("pl_#{PL_TARGET}_story_id".to_sym => nil)
          true if exported.count.positive?
        end
      end
    end
  end
end

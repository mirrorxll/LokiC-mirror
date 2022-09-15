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
      if @story_type.iteration.eql?(@iteration) && @story_type.staging_table && @iteration.creation && @iteration.schedule && @iteration.export.eql?(true)
        return false if @iteration.purge_export.eql?(true)

        stories       = @iteration.stories.where(backdated: false).where.not(published_at: nil)
        not_published = stories.map { |s| s.published_at > Time.now }.all?

        true if current_account.manager? || (current_account.content_manager? && not_published)
      end
    end
  end
end

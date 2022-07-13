module StoryTypes::ShowHelper
  def blocked_item?
    true unless @iteration.population.eql?(false) || @iteration.samples.eql?(false)
  end

  def purge_export_availability
    stories = @iteration.stories.where(backdated: false)
    if @story_type.iteration.eql?(@iteration) && @story_type.staging_table && @iteration.creation && @iteration.schedule
      if @iteration.export.eql?(true) && !@iteration.purge_export.eql?(true)
        story = stories.where.not(published_at: nil).order(:published_at).first
        return true unless story && story.published_at <= Time.now
      else
        exported = stories.where.not("pl_#{PL_TARGET}_story_id".to_sym => nil)
        return true if exported.count > 0
      end
    end
  end
end


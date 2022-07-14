module StoryTypes::ShowHelper
  def blocked_item?
    true unless @iteration.population.eql?(false) || @iteration.samples.eql?(false) || @iteration.purge_samples.eql?(false) || @iteration.creation.eql?(false) || @iteration.purge_creation.eql?(true) || @iteration.schedule.eql?(false) || @iteration.export.eql?(false) || @iteration.purge_export.eql?(true)
  end

  def purge_export_availability
    stories = @iteration.stories.where(backdated: false)
    if @story_type.iteration.eql?(@iteration) && @story_type.staging_table && @iteration.creation && @iteration.schedule
      if @iteration.export.eql?(true) && !@iteration.purge_export.eql?(true)
        story = stories.where.not(published_at: nil).order(:published_at).first
        pp '+++++++++++++++++++++++'*100, story
        www = true unless story && story.published_at <= Time.now
        pp ' >>>>>>>>>>>>>>>>>>> '*100, www
        return www
      elsif @iteration.export.eql?(true) && @iteration.purge_export.eql?(true)
        return false
      else
        exported = stories.where.not("pl_#{PL_TARGET}_story_id".to_sym => nil)
        uuu = true if exported.count > 0
        pp ' <<<<<<<<<<<<<<<<<<<< '*100, uuu, exported.count
        return uuu
      end
    end
  end
end


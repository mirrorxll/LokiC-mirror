# frozen_string_literal: true

module StoryTypesHelper # :nodoc:
  def frequency_name
    @story_type.frequency ? @story_type.frequency.name : '---'
  end

  def tag_name
    @story_type.tag ? @story_type.tag.name : '---'
  end

  def photo_bucket_name
    @story_type.photo_bucket ? @story_type.photo_bucket.name : '---'
  end

  def has_created_stories?(iteration)
    iteration.stories.where(sampled: nil).count > 0
  end

  def manager_or_editor
    true
  end
end

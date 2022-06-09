# frozen_string_literal: true

module StoryTypes
  class SidekiqBreaksController < StoryTypesController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    def cancel
      @story_type.sidekiq_break.update(cancel: true)
    end
  end
end

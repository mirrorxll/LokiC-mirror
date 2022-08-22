# frozen_string_literal: true

module StoryTypes
  class SidekiqBreaksController < StoryTypesController
    def cancel
      @story_type.sidekiq_break.update(cancel: true)
    end
  end
end

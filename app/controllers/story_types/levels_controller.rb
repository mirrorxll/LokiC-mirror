# frozen_string_literal: true

module StoryTypes
  class LevelsController < StoryTypesController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :find_level, only: :include

    def include
      render_403 && return if @story_type.level

      @story_type.update!(level: @level, current_account: current_account)
    end

    def exclude
      render_403 && return unless @story_type.level

      @story_type.update!(level: nil, current_account: current_account)
    end

    private

    def find_level
      @level = Level.find(params[:id])
    end
  end
end

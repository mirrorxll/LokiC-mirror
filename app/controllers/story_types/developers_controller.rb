# frozen_string_literal: true

module StoryTypes
  class DevelopersController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :find_developer

    def include
      render_403 && return unless @developer

      @story_type.update!(developer: @developer, distributed_at: Time.now, current_account: current_account)
    end

    def exclude
      render_403 && return unless @developer

      @story_type.update!(developer: nil, distributed_at: nil, current_account: current_account)
    end

    private

    def find_developer
      @developer = @story_type.developer || Account.find(params[:id])
    end
  end
end

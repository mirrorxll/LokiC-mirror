# frozen_string_literal: true

module ArticleTypes
  class DevelopersController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_developer, only: :include

    def include
      render_403 && return if @article_type.developer

      @article_type.update!(developer: @developer, current_account: current_account)
    end

    def exclude
      render_403 && return unless @article_type.developer

      @article_type.update!(developer: nil, current_account: current_account)
    end

    private

    def find_developer
      @developer = Account.find(params[:id])
    end
  end
end

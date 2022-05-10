# frozen_string_literal: true

class TableLocationsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def new
    @model = Object.const_get(params[:model]).find(params[:model_id])
  end
end

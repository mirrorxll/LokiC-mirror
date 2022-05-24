# frozen_string_literal: true

class FactoidRequestsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  private

  def find_factoid_request
    @factoid_request = FactoidRequest.find(params[:id] || params[:factoid_request_id])
  end
end

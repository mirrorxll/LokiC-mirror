# frozen_string_literal: true

class FactoidTypesController < ApplicationController
  before_action -> { authorize!('factoid_types') }

  before_action :find_article_type
  before_action :set_article_type_iteration

  private

  def find_article_type
    @factoid_type = ArticleType.find(params[:factoid_type_id] || params[:id])
  end

  def set_article_type_iteration
    @iteration =
      if params[:iteration_id]
        ArticleTypeIteration.find(params[:iteration_id])
      else
        @factoid_type.iteration
      end
  end
end

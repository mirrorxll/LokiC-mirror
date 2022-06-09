# frozen_string_literal: true

class FactoidTypesController < ApplicationController
  private

  def find_article_type
    @factoid_type = ArticleType.find(params[:factoid_type_id] || params[:id])
  end
end

# frozen_string_literal: true

class DataSetsController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_data_set, except: %i[index create]

  private

  def find_data_set
    @data_set = DataSet.find(params[:id] || params[:id])
  end
end

# frozen_string_literal: true

class IndicesController < ApplicationController
  before_action :staging_table

  def new
    flash[:error] =
      if @staging_table.nil?
        'Table was attached or delete. Please update the page.'
      elsif StagingTable.not_exists?(@staging_table.name)
        'Someone drop or rename table for this story type. Please check it.'
      end

    if flash[:error].nil?
      @staging_table.index.drop
      @staging_table.sync
      @columns = @staging_table.columns.names_ids
    end
  end

  def create
    @staging_table.index.add(index_params)
    @staging_table.sync

    redirect_to @story_type
  end

  def destroy
    @staging_table.index.drop
    @staging_table.sync

    redirect_to @story_type
  end

  private

  def index_params
    if params[:index]
      ids = params.require(:index).permit(column_ids: [])[:column_ids]
      ids.map!(&:to_sym)
    else
      []
    end
  end

  def staging_table
    @staging_table = @story_type.staging_table
  end
end

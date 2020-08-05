# frozen_string_literal: true

class IndicesController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :staging_table

  def new
    flash.now[:error] =
      if @staging_table.nil?
        detached_or_delete
      elsif StagingTable.not_exists?(@staging_table.name)
        'Someone drop or rename table for this story type. Please check it.'
      end

    if flash.now[:error].nil?
      @staging_table.index.drop
      @staging_table.sync
      @columns = @staging_table.columns.names_ids
    end
  end

  def create
    flash.now[:error] =
      if @staging_table.nil?
        detached_or_delete
      else
        @staging_table.index.add(uniq_index_params)
      end

    @staging_table.sync if flash.now[:error].nil?
    render 'staging_tables/show'
  end

  def destroy
    flash.now[:error] =
      if @staging_table.nil?
        detached_or_delete
      else
        @staging_table.index.drop
      end

    @staging_table.sync if flash.now[:error].nil?
    render 'staging_tables/show'
  end

  private

  def uniq_index_params
    if params[:index]
      params.require(:index).permit(column_ids: [])[:column_ids].map!(&:to_sym)
    else
      []
    end
  end

  def staging_table
    @staging_table = @story_type.staging_table
  end
end

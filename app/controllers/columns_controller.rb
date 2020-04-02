# frozen_string_literal: true

class ColumnsController < ApplicationController
  def edit
    @staging_table = @story_type.staging_table

    flash[:error] =
      if @staging_table.nil?
        'Table was attached or delete. Please update the page.'
      elsif !StagingTable.exists?(@staging_table.name)
        'Someone drop or rename table for this story type. Please check it.'
      end

    @staging_table.sync
  end

  def update
    @staging_table = @story_type.staging_table
    @staging_table.columns.modify(columns_params)
    @staging_table.sync

    redirect_to @story_type
  end

  private

  def columns_params
    columns = params[:columns] ? params.require(:columns).permit!.to_hash : {}
    LokiC::StagingTable.columns_transform(columns, :front)
  end
end

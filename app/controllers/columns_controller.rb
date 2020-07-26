# frozen_string_literal: true

class ColumnsController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :staging_table

  def edit
    flash.now[:error] =
      if @staging_table.nil?
        detached_or_delete
      elsif !StagingTable.exists?(@staging_table.name)
        'Someone drop or rename table for this story type. Please check it.'
      end

    @staging_table.sync if flash.now[:error].nil?
  end

  def update
    flash.now[:error] =
      if @staging_table.nil?
        detached_or_delete
      else
        @staging_table.columns.modify(columns_params)
      end

    @staging_table.sync if flash.now[:error].nil?
    render 'staging_tables/show'
  end

  private

  def columns_params
    columns = params[:columns] ? params.require(:columns).permit!.to_hash : {}
    Table.columns_transform(columns, :front)
  end

  def staging_table
    @staging_table = @story_type.staging_table
  end
end

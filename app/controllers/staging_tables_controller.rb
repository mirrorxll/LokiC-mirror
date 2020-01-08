# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :staging_table_params, only: %i[create update]

  def show
    @staging_table = @story.staging_table
  end

  def create
    flash[:error] =
      if @story.staging_table
        'Table for this story type already exist.'
      elsif StagingTable.exists?(params[:staging_table][:name])
        'Table with passed name already exist.'
      else
        StagingTable.generate(@staging_table_params)
      end

    @story.create_staging_table(@staging_table_params) unless flash[:error]
    render 'create_update'
  end

  def edit; end

  def update
    flash[:error] =
      if StagingTable.exists?(params[:staging_table][:name])
        @story.staging_table.modify(@staging_table_params)
      else
        'Table was removed or renamed.'
      end

    @story.staging_table.update(@staging_table_params) unless flash[:error]
    render 'create_update'
  end

  def truncate
    @story.staging_table.truncate
  end

  def destroy
    @story.staging_table.drop_table
    @story.staging_table.delete
  end

  private

  def staging_table_params
    @staging_table_params = StagingTable.name_columns_from(params)
  end
end

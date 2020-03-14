# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :new_staging_table_params, only: %i[create]

  def show; end

  def create
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already exist.'
      end

    if flash[:error].nil?
      @staging_table = StagingTable.create(story_type: @story_type)
      @staging_table.create_tbl(@staging_table_columns)
    end

    render 'create_update'
  end

  def attach

  end

  def edit; end

  def update
    flash[:error] =
      if StagingTable.exists?(params[:staging_table][:name])
        @story_type.staging_table.modify(@staging_table_params)
      else
        'Table was removed or renamed.'
      end

    @story_type.staging_table.update(@staging_table_params) unless flash[:error]
    render 'create_update'
  end

  def truncate
    @story_type.staging_table.truncate
  end

  def destroy
    @story_type.staging_table.drop_table
    @story_type.staging_table.delete
  end

  private

  def new_staging_table_params
    columns = params.require(:staging_table).permit!
    @staging_table_columns = LokiC::StagingTable::Columns.transform_init(columns.to_h)
  end

  def attach_staging_table_params
    params.require(:table).permit(:name)
  end

  def exist_staging_table_params

  end
end

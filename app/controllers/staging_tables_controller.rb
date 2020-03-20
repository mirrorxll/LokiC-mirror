# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :attach_staging_table_params, only: %i[attach]
  before_action :new_staging_table_params, only: %i[create]

  def attach
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already attached. Please update the page'
      elsif StagingTable.find_by(name: @staging_table_params[:name])
        'This table already attached to another story type.'
      elsif !StagingTable.tbl_exists?(@staging_table_params[:name])
        'Table not found'
      end

    if flash[:error].nil?
      @story_type.create_staging_table(@staging_table_params)
    end

    render 'attach_create_update'
  end

  def detach
    @story_type.staging_table.delete

    render 'detach_delete'
  end

  def create
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already exist. Please update page'
      end

    if flash[:error].nil?
      @staging_table = StagingTable.create(story_type: @story_type)
      @staging_table.create_tbl(@staging_table_columns)
    end

    render 'attach_create_update'
  end

  def edit
    @staging_table = @story_type.staging_table

    flash[:error] =
      if @staging_table.nil?
        'Table was attached or delete. Please update the page.'
      elsif !StagingTable.tbl_exists?(@staging_table.name)
        'Someone drop table for this story type. Please check it.'
      end

    @staging_table.prepare_editable if flash[:error].nil?

    render 'edit'
  end

  def update
    flash[:error] =
      if StagingTable.exists?(params[:staging_table][:name])
        @story_type.staging_table.modify(@staging_table_params)
      else
        'Table was removed or renamed.'
      end

    @story_type.staging_table.update(@staging_table_params) unless flash[:error]
    render 'attach_create_update'
  end

  def truncate
    @story_type.staging_table.truncate
  end

  def destroy
    @story_type.staging_table.drop_table
    @story_type.staging_table.delete

    render 'detach_delete'
  end

  private

  def new_staging_table_params
    columns = params.require(:staging_table).permit!
    @staging_table_columns =
      LokiC::StagingTable::Columns.transform_init(columns.to_h)
  end

  def attach_staging_table_params
    @staging_table_params =
      params.require(:staging_table).permit(:name)
  end

  def exist_staging_table_params

  end
end

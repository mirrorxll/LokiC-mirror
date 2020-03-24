# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :attach_staging_table, only: %i[attach]
  before_action :staging_table_columns, only: %i[create update]

  def attach
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already attached. Please update the page'
      elsif StagingTable.find_by(name: @staging_table_name)
        'This table already attached to another story type.'
      elsif !StagingTable.tbl_exists?(@staging_table_name)
        'Table not found'
      end

    if flash[:error].nil?
      @story_type.create_staging_table(name: @staging_table_name)
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
        'Someone drop or rename table for this story type. Please check it.'
      end

    if flash[:error].nil?
      @staging_table.save_columns
    end

    render 'edit'
  end

  def update
    @staging_table = @story_type.staging_table
    @staging_table.modify_tbl(@staging_table_columns)

    render 'attach_create_update'
  end

  def truncate
    @story_type.staging_table.truncate_tbl
  end

  def drop
    @story_type.staging_table.drop_tbl
    @story_type.staging_table.delete

    render 'detach_delete'
  end

  private

  def staging_table_columns
    columns = params.require(:staging_table).permit!.to_hash
    @staging_table_columns =
      LokiC::StagingTable::Columns.frontend_transform(columns)
  end

  def attach_staging_table
    @staging_table_name =
      params.require(:staging_table).permit(:name)[:name]
  end
end

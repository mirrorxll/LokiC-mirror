# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :attach_staging_table, only: %i[attach]

  def show; end

  def attach
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already attached. Please update the page'
      elsif StagingTable.find_by(name: @staging_table_name)
        'This table already attached to another story type.'
      elsif !StagingTable.exists?(@staging_table_name)
        'Table not found'
      end

    if flash[:error].nil?
      @story_type.create_staging_table(name: @staging_table_name)
      @story_type.staging_table.synchronization
    end

    render 'show'
  end

  def detach
    @story_type.staging_table.delete

    render 'new'
  end

  def new; end

  def create
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already exist. Please update page'
      end

    if flash[:error].nil?
      @story_type.create_staging_table(columns: staging_table_columns)
    end

    render 'show'
  end

  def edit
    @staging_table = @story_type.staging_table

    flash[:error] =
      if @staging_table.nil?
        'Table was attached or delete. Please update the page.'
      elsif !StagingTable.exists?(@staging_table.name)
        'Someone drop or rename table for this story type. Please check it.'
      end
  end

  def update
    @staging_table = @story_type.staging_table
    @staging_table.modify_columns(staging_table_columns)
    @staging_table.synchronization

    render 'show'
  end

  def truncate
    @story_type.staging_table.truncate
  end

  def destroy
    @story_type.staging_table.destroy

    render 'new'
  end

  private

  def staging_table_columns
    columns = params.require(:staging_table).permit!.to_hash
    LokiC::StagingTable::Columns.frontend_transform(columns)
  end

  def attach_staging_table
    @staging_table_name =
      params.require(:staging_table).permit(:name)[:name]
  end
end

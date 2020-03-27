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
      @story_type.staging_table.sync
    end

    render 'show'
  end

  def detach
    @staging_table = @story_type.staging_table

    @staging_table.columns&.delete
    @staging_table.indices&.delete
    @staging_table&.delete

    render 'add_table'
  end

  def create
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already exist. Please update page'
      end

    if flash[:error].nil?
      @story_type.create_staging_table
    end

    render 'show'
  end

  def sync
    @story_type.staging_table.sync

    render 'show'
  end

  def truncate
    @story_type.staging_table.truncate
  end

  def destroy
    @story_type.staging_table.destroy

    render 'add_table'
  end

  private

  def attach_staging_table
    @staging_table_name =
      params.require(:staging_table).permit(:name)[:name]
  end
end

# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :attach_staging_table, only: %i[attach]
  before_action :staging_table

  def show; end

  def attach
    flash[:error] =
      if @staging_table.present?
        'Table for this story type already attached. Please update the page'
      elsif StagingTable.find_by(name: @staging_table_name)
        'This table already attached to another story type.'
      elsif StagingTable.not_exists?(@staging_table_name)
        'Table not found'
      end

    @story_type.create_staging_table(name: @staging_table_name) if flash[:error].nil?

    render 'show'
  end

  def create
    flash[:error] =
      ('Table for this story type already exist. Please update page' if @staging_table.present?)

    @story_type.create_staging_table if flash[:error].nil?

    render 'show'
  end

  def sync
    @staging_table.sync

    render 'show'
  end

  def destroy
    @staging_table.destroy

    render 'new'
  end

  def truncate
    @staging_table.truncate
    @story_type.update_iteration(population: nil)

    render 'populations/destroy'
  end

  private

  def attach_staging_table
    @staging_table_name =
      params.require(:staging_table).permit(:name)[:name]
  end

  def staging_table
    @staging_table = @story_type.staging_table
  end
end

# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?
  before_action :attach_staging_table, only: %i[attach]
  before_action :staging_table

  def create
    flash.now[:error] =
      if @staging_table.present?
        'Table for this story type already exist. Please update the page.'
      elsif StagingTable.find_by(name: "s#{@story_type.id}_staging")
        "Table with name 's#{@story_type.id}_staging' already attached to another story type."
      end

    @story_type.create_staging_table if flash.now[:error].nil?
    render 'show'
  end

  def attach
    flash.now[:error] =
      if @staging_table.present?
        'Table for this story type already attached. Please update the page.'
      elsif StagingTable.find_by(name: @staging_table_name)
        "This table already attached to another story type. Please pass another staging table's name."
      elsif StagingTable.not_exists?(@staging_table_name)
        'Table not found'
      end

    @story_type.create_staging_table(name: @staging_table_name) if flash.now[:error].nil?
    render 'show'
  end

  def detach
    if @staging_table.nil?
      flash.now[:error] = detached_or_delete
    else
      @staging_table.destroy
    end

    render 'new'
  end

  def sync
    if @staging_table.nil?
      flash.now[:error] = detached_or_delete
    else
      @staging_table.sync
    end

    render 'show'
  end

  def section
    flash.now[:error] = detached_or_delete if @staging_table.nil?
    render 'show'
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

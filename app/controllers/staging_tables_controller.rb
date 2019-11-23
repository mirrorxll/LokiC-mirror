# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :find_story

  def show
    @staging_table = @story.staging_table
  end

  def create
    if @story.staging_table
      flash[:error] = "Table for this story type already exist."
    elsif StagingTable.exists?(params[:staging_table][:name])
      flash[:error] = "Table with passed name already exist."
    else
      @story.create_staging_table(staging_table_params).generate
    end

    render 'create_update'
  end

  def edit; end

  def update
    if @story.staging_table
      updated_params = @story.staging_table.modify(staging_table_params)
      @story.staging_table.update(updated_params)
    else
      flash[:error] = "Table was removed or renamed."
    end

    render 'create_update'
  end

  def destroy
    @story.staging_table.delete
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def staging_table_params
    StagingTable.name_columns_from(params)
  end
end

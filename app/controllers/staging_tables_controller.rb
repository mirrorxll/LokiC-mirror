# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :find_story

  def show
    @staging_table = @story.staging_table
  end

  def new
    @staging_table = StagingTable.new
  end

  def create
    @staging_table = StagingTable.new(staging_table_params)

    if @staging_table.save
      'Create'
    else
      render :new
    end
  end

  def edit
    @staging_table = @story.staging_table
  end

  def update
    if @story.staging_table.update(staging_table_params)
      'Update'
    else
      render :edit
    end
  end

  def destroy
    @story.staging_table.delete
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def staging_table_params
    params.require(:staging_table).permit(:name, :columns)
  end
end

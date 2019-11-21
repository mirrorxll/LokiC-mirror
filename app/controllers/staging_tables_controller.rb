# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :find_story

  def show
    @staging_table = @story.staging_table
  end

  def create
    @staging_table = @story.build_staging_table(staging_table_params)

    if @staging_table.save
      @staging_table.generate
    else
      flash[:error] = "Table wasn't created"
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
    StagingTable.transform(params)
  end
end

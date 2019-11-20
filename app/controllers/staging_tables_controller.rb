# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :find_story

  def show
    @staging_table = @story.staging_table
  end

  def create
    # <<<<<<<<<<<<
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
    index = 1
    table_params = { name: params[:staging_table].delete(:name), columns: [] }

    loop do
      break if params[:staging_table][:"column_name_#{index}"].nil? ||
          params[:staging_table][:"column_type_#{index}"].nil?

      table_params[:columns] << {
          "#{params[:staging_table][:"column_name_#{index}"]}":
              params[:staging_table][:"column_type_#{index}"]
      }
      index += 1
    end

    table_params
  end
end

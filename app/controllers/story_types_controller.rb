# frozen_string_literal: true

class StoryTypesController < ApplicationController # :nodoc:
  before_action :find_data_set, only: %i[new create]
  before_action :find_story_type, except: %i[index new create properties]
  skip_before_action :find_parent_story_type, except: :properties

  def index
    @story_types = StoryType.all

    filter_params.each do |key, value|
      @story_types = @story_types.public_send(key, value) if value.present?
    end
  end

  def show; end

  def new
    @story_type = @data_set.story_types.build
  end

  def create
    @story_type = @data_set.story_types.build(story_type_params)
    @story_type.editor = current_account

    if @story_type.save
      redirect_to data_set_path(@data_set)
    else
      render :new
    end
  end

  def edit; end

  def update
    @story_type.update!(story_type_params)
  end

  def properties; end

  def destroy
    @story_type.destroy
  end

  private

  def find_data_set
    @data_set = DataSet.find(params[:data_set_id])
  end

  def find_story_type
    @story_type = StoryType.find(params[:id])
  end

  def story_type_params
    params.require(:story_type).permit(:name)
  end

  def filter_params
    params.slice(
      :editor, :developer, :data_tes, :client, :frequency, :dev_status
    )
  end
end

# frozen_string_literal: true

class StoryTypesController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type, except: :properties

  before_action :redirect_to_separate_root, only: :index
  before_action :render_400_editor,         only: %i[distributed show], if: :editor?
  before_action :render_400_developer,      only: %i[new create edit update properties destroy], if: :developer?
  before_action :find_data_set,             only: %i[new create]
  before_action :find_story_type,           except: %i[index distributed new create properties]
  before_action :set_iteration,             only: :show

  def index
    @story_types = StoryType.order(id: :desc)

    filter_params.each do |key, value|
      @story_types = @story_types.public_send(key, value) if value.present?
    end
  end

  def distributed
    @story_types = StoryType.order(id: :desc).where(developer: current_account)
    render 'index'
  end

  def show
    @tab_title = "##{@story_type.id} #{@story_type.name}"
  end

  def canceling_edit; end

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

  def redirect_to_separate_root
    return if manager?

    redirect_to data_sets_path if editor?
    redirect_to distributed_story_types_path if developer?
  end

  def check_access
    redirect_to root_path
  end

  def find_data_set
    @data_set = DataSet.find(params[:data_set_id])
  end

  def find_story_type
    @story_type = StoryType.find(params[:id])
  end

  def story_type_params
    params.require(:story_type).permit(:name)
  end

  def set_iteration
    @iteration =
      if params[:iteration]
        iteration = Iteration.find(params[:iteration])
        @story_type.update(current_iteration: iteration)
        iteration
      else
        @story_type.current_iteration
      end

    @story_type.staging_table&.default_iter_id if StagingTable.exists?(@story_type.staging_table&.name)
  end

  def filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(:data_set, :developer, :frequency, :status)
  end
end

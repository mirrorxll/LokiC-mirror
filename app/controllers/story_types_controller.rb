# frozen_string_literal: true

class StoryTypesController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type, except: :properties_form
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_data_set,            only: %i[new create]
  before_action :find_story_type,          except: %i[index new create properties_form]
  before_action :set_story_type_iteration, except: %i[index new create properties_form change_data_set]
  before_action :message,                  only: :update_sections
  before_action :find_current_data_set,    only: :change_data_set

  def index
    @grid_params = if request.parameters[:story_types_grid]
                     request.parameters[:story_types_grid]
                   elsif request.parameters[:archive_story_types_grid]
                     request.parameters[:archive_story_types_grid]
                   else
                     developer? ? { developer: current_account.id } : {}
                   end

    if params[:archived] || request.parameters[:archive_story_types_grid]
      @story_types_grid = ArchiveStoryTypesGrid.new(@grid_params) { StoryType.archived }
      # @story_types_grid.scope { StoryType.archived }
    else
      @story_types_grid = StoryTypesGrid.new(@grid_params) { |scope| scope.where(archived: false) }
      # @story_types_grid.scope { StoryType.all }
    end
    # @story_types_grid.scope { StoryType.archived } if params[:archived] || request.parameters[:story_types_grid]

    respond_to do |f|
      f.html do
        @story_types_grid.scope { |scope| scope.page(params[:page]).per(50) }
      end

      f.csv do
        send_data(
          @story_types_grid.to_csv,
          type: 'text/csv',
          disposition: 'inline',
          filename: "lokic_story_types_#{Time.now}.csv"
        )
      end
    end
  end

  def show
    @tab_title = "LokiC::##{@story_type.id} #{@story_type.name}"
  end

  def new
    @story_type = @data_set.story_types.build
  end

  def create
    @story_type = @data_set.story_types.build(new_story_type_params)

    if @story_type.save!
      redirect_to data_set_path(@data_set)
    else
      render :new
    end
  end

  def edit; end

  def update
    @story_type.update!(exist_story_type_params)
  end

  def properties_form; end

  def change_data_set
    @story_type.update!(change_data_set_params)
  end

  def update_sections; end

  private

  def check_access
    redirect_to root_path
  end

  def find_data_set
    @data_set = DataSet.find(params[:data_set_id])
  end

  def find_story_type
    @story_type = StoryType.find(params[:id])
  end

  def new_story_type_params
    permitted = params.require(:story_type).permit(:name, :comment, :gather_task, :migrated)
    migrated = permitted[:migrated].eql?('1')
    status_name = migrated ? 'migrated' : 'not started'

    {
      editor: current_account,
      name: permitted[:name],
      comment: permitted[:comment],
      gather_task: permitted[:gather_task],
      migrated: migrated,
      status: Status.find_by(name: status_name),
      photo_bucket: @data_set.photo_bucket,
      last_status_changed_at: Time.now.getlocal('-05:00'),
      current_account: current_account
    }
  end

  def exist_story_type_params
    attrs = params.require(:story_type).permit(:name, :comment, :gather_task)
    attrs[:current_account] = current_account
    attrs
  end

  def filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(:data_set, :developer, :frequency, :status)
  end

  def change_data_set_params
    attrs = params.require(:story_type).permit(:data_set_id)
    attrs[:current_account] = current_account
    attrs
  end

  def find_current_data_set
    @current_data_set = DataSet.find(params[:current_data_set_page_id])
  end

  def message
    @key = params[:message][:key].to_sym
    flash.now[@key] = params[:message][@key]
  end
end

# frozen_string_literal: true

class StoryTypesController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type, except: :properties

  before_action :redirect_to_separate_root, only: :index
  before_action :render_400_editor,         only: :show, if: :editor?
  before_action :render_400_developer,      only: %i[new create edit update properties destroy], if: :developer?
  before_action :find_data_set,             only: %i[new create]
  before_action :find_story_type,           except: %i[index new create properties]
  before_action :set_iteration,             except: %i[index new create properties change_data_set]
  before_action :message,                   only: :update_sections

  def index
    @grid_params = if request.parameters[:story_types_grid]
                     request.parameters[:story_types_grid]
                   else
                     developer? ? { order: :id, descending: true, developer: current_account.id } : { order: :id, descending: true }
                   end

    @story_types_grid = StoryTypesGrid.new(@grid_params)
    respond_to do |f|
      f.html do
        @story_types_grid.scope { |scope| scope.page(params[:page]).per(50) }
      end
      f.csv do
        send_data @story_types_grid.to_csv,
                  type: 'text/csv',
                  disposition: 'inline',
                  filename: "LokiC_StoryTypes_#{Time.now}.csv"
      end
    end
  end

  def show
    render_400 and return if developer? && @story_type.developer != current_account

    @tab_title = "LokiC::##{@story_type.id} #{@story_type.name}"
  end

  def canceling_edit; end

  def new
    @story_type = @data_set.story_types.build
  end

  def create
    @story_type = @data_set.story_types.build(story_type_params)
    @story_type.editor = current_account
    @story_type.photo_bucket = @data_set.photo_bucket

    if @story_type.save!
      @data_set.client_publication_tags.each do |client_publication_tag|
        @story_type.clients_publications_tags.build(client: client_publication_tag.client,
                                                    publication: client_publication_tag.publication,
                                                    tag: client_publication_tag.tag).save!
      end

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

  def change_data_set
    @old_data_set = @story_type.data_set
    @story_type.update(change_data_set_params)
  end

  def update_sections; end

  private

  def redirect_to_separate_root
    return if manager?

    redirect_to data_sets_path if editor?
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

  def filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(:data_set, :developer, :frequency, :status)
  end

  def change_data_set_params
    p params.require(:story_type).permit(:data_set_id)
  end

  def message
    @key = params[:message][:key].to_sym
    flash.now[@key] = params[:message][@key]
  end
end

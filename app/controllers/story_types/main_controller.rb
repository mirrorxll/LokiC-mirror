# frozen_string_literal: true

module StoryTypes
  class MainController < StoryTypesController # :nodoc:
    before_action :find_data_set,            only: %i[new create]
    before_action :find_story_type,          except: %i[index new create]
    before_action :set_story_type_iteration, except: %i[index new create properties_form change_data_set]
    before_action :message,                  only: :update_sections
    # before_action :find_current_data_set,    only: :change_data_set

    before_action :grid_lists, only: %i[index show]
    before_action :current_list, only: :index
    before_action :generate_grid, only: :index

    def index
      @tab_title = 'LokiC :: StoryTypes'
    end

    def show
      @tab_title = "LokiC :: StoryType ##{@story_type.id} <#{@story_type.name}>"
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

    # def change_data_set
    #   @story_type.update!(change_data_set_params)
    # end

    def update_sections; end

    private

    def grid_lists
      @lists = HashWithIndifferentAccess.new

      @lists['all'] = {}     if @permissions['grid']['all']
      @lists['archived'] = { archived: true } if @permissions['grid']['archived']
    end

    def current_list
      keys = @lists.keys
      @current_list = keys.include?(params[:list]) ? params[:list] : keys.first
    end

    def generate_grid
      return unless @current_list

      grid_params = request.parameters[:story_types_grid] || {}
      grid_params.merge!({ current_account: current_account, env: env })

      @grid = StoryTypesGrid.new(grid_params) { |scope| scope.where(@lists[@current_list]) }

      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end

    def check_access
      redirect_to root_path
    end

    def find_data_set
      @data_set = DataSet.find(params[:data_set_id])
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

    # def change_data_set_params
    #   attrs = params.require(:story_type).permit(:data_set_id)
    #   attrs[:current_account] = current_account
    #   attrs
    # end

    def find_current_data_set
      @current_data_set = DataSet.find(params[:current_data_set_page_id])
    end

    def message
      @key = params[:message][:key].to_sym
      flash.now[@key] = params[:message][@key]
    end

    def env
      %w[development test].include?(Rails.env) ? 'staging' : Rails.env
    end
  end
end

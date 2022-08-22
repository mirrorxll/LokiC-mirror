# frozen_string_literal: true

module StoryTypes
  class MainController < StoryTypesController # :nodoc:
    before_action :find_story_type,          except: %i[index create]
    before_action :set_story_type_iteration, except: %i[index create]

    before_action :grid_lists,     only: %i[index show]
    before_action :current_list,   only: :index
    before_action :generate_grid,  only: :index
    before_action :access_to_show, only: :show

    def index
      @tab_title = 'LokiC :: StoryTypes'

      respond_to do |f|
        f.html do
          @grid.scope { |scope| scope.page(params[:page]) }
        end
        f.csv do
          send_data @grid.to_csv, type: 'text/csv', disposition: 'inline',
                    filename: "lokiC_story_types_#{Time.now}.csv"
        end
      end
    end

    def show
      @tab_title = "LokiC :: StoryType ##{@story_type.id} <#{@story_type.name}>"
      @content_developers = AccountRole.find_by(name: 'Content Developer').accounts
    end

    def create
      @story_type = StoryType.new(new_story_type_params)

      redirect_to @story_type.data_set || @story_type if @story_type.save!
    end

    def edit; end

    def update
      @story_type.update!(exist_story_type_params)
    end

    def canceling_edit; end

    private

    def grid_lists
      statuses = Status.hle_statuses(created: true, migrated: true, inactive: true)
      @lists = HashWithIndifferentAccess.new

      @lists['assigned'] = { developer: current_account, status: statuses } if @story_types_permissions['grid']['assigned']
      @lists['created'] = { editor: current_account, status: statuses }     if @story_types_permissions['grid']['created']
      @lists['all'] = { status: statuses }                                  if @story_types_permissions['grid']['all']
      @lists['archived'] = { status: Status.find_by(name: 'archived') }     if @story_types_permissions['grid']['archived']
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
    end

    def find_data_set
      @data_set = DataSet.find(params[:data_set_id])
    end

    def access_to_show
      archived = Status.find_by(name: 'archived')

      return if @lists['yours'] && @story_type.account.eql?(current_account)
      return if @lists['all'] && @story_type.status != archived
      return if @lists['archived'] && @story_type.status.eql?(archived)

      flash[:error] = { story_type: :unauthorized }
      redirect_back fallback_location: root_path
    end

    def new_story_type_params
      permitted = params.require(:story_type).permit(:name, :data_set_id)

      story_type_params = {
        editor: current_account,
        name: permitted[:name],
        data_set_id: permitted[:data_set_id],
        status: Status.find_by(name: 'created and in queue'),
        last_status_changed_at: Time.now.getlocal('-05:00'),
        current_account: current_account
      }

      story_type_params.merge!(photo_bucket: @data_set.photo_bucket) if @data_set
      story_type_params
    end

    def exist_story_type_params
      attrs = params.require(:story_type).permit(:name, :comment, :gather_task)
      attrs[:current_account] = current_account
      attrs
    end

    def env
      %w[staging development test].include?(Rails.env) ? 'staging' : Rails.env
    end
  end
end

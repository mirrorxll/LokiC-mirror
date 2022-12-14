# frozen_string_literal: true

module StoryTypes
  class MainController < StoryTypesController # :nodoc:
    before_action :find_story_type,          except: %i[index create]
    before_action :set_story_type_iteration, except: %i[index create]

    before_action :grid_lists,         only: %i[index show]
    before_action :current_list,       only: :index
    before_action :generate_grid,      only: :index
    before_action :access_to_show,     only: :show
    before_action :content_developers, only: %i[show update canceling_edit]

    def index
      @tab_title = 'LokiC :: StoryTypes'

      respond_to do |f|
        f.html do
          @grid.scope { |scope| scope.page(params[:page]).per(30) }
        end
        f.csv do
          send_data @grid.to_csv, type: 'text/csv', disposition: 'inline',
                                  filename: "lokiC_story_types_#{Time.now}.csv"
        end
      end
    end

    def show
      @tab_title = "LokiC :: StoryType ##{@story_type.id} <#{@story_type.name}>"
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
      statuses      = Status.hle_statuses(created: true, migrated: true, inactive: true)
      allowed_grids = current_account.ordered_lists.where(branch_name: 'story_types').order(:position)
      @lists        = HashWithIndifferentAccess.new

      allowed_grids.each do |grid|
        @lists[grid.grid_name] = { status: statuses }

        @lists[grid.grid_name].merge!(developer: current_account)               if grid.grid_name.eql?('assigned')
        @lists[grid.grid_name].merge!(editor: current_account)                  if grid.grid_name.eql?('created')
        @lists[grid.grid_name].merge!(status: Status.find_by(name: 'archived')) if grid.grid_name.eql?('archived')
      end
    end

    def current_list
      keys = @lists.keys
      @current_list =
        if keys.include?(params[:list])
          params[:list]
        else
          current_account.ordered_lists.first_grid('story_types')
        end
    end

    def generate_grid
      return unless @current_list

      @grid = StoryTypesGrid.new(params[:story_types_grid]) do |scope|
        scope.where(@lists[@current_list])
      end

      @grid.current_account = current_account
      @grid.env = env
    end

    def find_data_set
      @data_set = DataSet.find(params[:data_set_id])
    end

    def access_to_show
      archived = Status.find_by(name: 'archived')

      return if @lists['assigned'] && @story_type.developer.eql?(current_account)
      return if @lists['created'] && @story_type.editor.eql?(current_account)
      return if @lists['all'] && @story_type.status != archived
      return if @lists['archived'] && @story_type.status.eql?(archived)

      flash[:error] = { story_type: :unauthorized }
      redirect_back fallback_location: root_path
    end

    def content_developers
      @content_developers = AccountRole.find_by(name: 'Content Developer').accounts.ordered
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

# frozen_string_literal: true

module StoryTypes
  class SamplesController < StoryTypesController # :nodoc:
    before_action :find_sample, only: %i[show edit update]
    before_action :generate_grid, only: :index

    def index
      @stories_count = [@iteration.stories.scheduled_count, @iteration.stories.backdated_count]
      @tab_title = "LokiC :: StoryType ##{@story_type.id} :: Samples"

      respond_to do |f|
        f.html do
          @grid.scope { |scope| scope.page(params[:page]) }
        end
        f.csv do
          send_data @grid.to_csv, type: 'text/csv', disposition: 'inline',
                    filename: "LokiC_##{@story_type.id}_#{@story_type.name}_#{@iteration.name}_stories_#{Time.now}.csv"
        end
      end
    end

    def show
      @tab_title = "LokiC :: StoryType ##{@story_type.id} :: Story ##{@sample.id}"

      respond_to do |format|
        format.html { render 'show' }
        format.js { render 'to_tab' }
      end
    end

    def create_and_gen_auto_feedback
      @iteration.update!(samples: false, current_account:@current_account)
      send_to_action_cable(@story_type, 'samples', 'creation in the process')

      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        "rake story_type:iteration:samples_and_auto_feedback iteration_id=#{@iteration.id} "\
        "account_id=#@current_account.id} options='#{stories_params.to_json}' &"
      )

      render 'story_types/creations/execute'
    end

    def purge_sampled
      @iteration.update!(purge_samples: false, current_account: @current_account)
      send_to_action_cable(@story_type, 'samples', 'purging in progress')

      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        'rake story_type:iteration:purge_samples_and_auto_feedback '\
        "iteration_id=#{@iteration.id} account_id=#{current_account.id} &"
      )
    end

    private

    def find_sample
      @sample = Story.find(params[:id])
    end

    def stories_params
      params.require(:samples).permit(:row_ids, columns: {}).to_hash
    end

    def generate_grid
      grid_params = request.parameters[:story_type_iteration_stories_grid] || {}
      grid_params.merge!(client_ids: @story_type.clients.pluck(:name, :id))

      @grid = StoryTypeIterationStoriesGrid.new(grid_params) do |scope|
        scope.where(story_type_id: params[:story_type_id], story_type_iteration_id: params[:iteration_id])
      end
    end
  end
end

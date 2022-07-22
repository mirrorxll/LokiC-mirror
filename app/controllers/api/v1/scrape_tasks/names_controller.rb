
module Api
  module V1
    module ScrapeTasks
      class NamesController < ScrapeTasksController
        def show
          render json: ScrapeTask.all.map(&:name)
        end
      end
    end
  end
end

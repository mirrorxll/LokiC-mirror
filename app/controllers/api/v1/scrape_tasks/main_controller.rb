
module Api
  module V1
    module ScrapeTasks
      class MainController < ScrapeTasksController
        before_action :find_scrape_task
        def show
          render json: {
            status: @scrape_task.status.name,
            created_by: @scrape_task.creator.name,
            created_at: @scrape_task.created_at.utc,
            updated_at: @scrape_task.updated_at.utc,
            main_info: {
              tags: @scrape_task.tags.map(&:name),
              name: @scrape_task.name,
              multi_tasks: @scrape_task.tasks.pluck(:id),
              gather_task_id: @scrape_task.gather_task,
              deadline: @scrape_task.deadline,
              state: @scrape_task.state&.name,
              URL: @scrape_task.datasource_url,
              comment_on_datasource: @scrape_task.datasource_comment&.body,
              scrapable: @scrape_task.scrapable.eql?(-1) ? nil : @scrape_task.scrapable.eql?(1),
              comment_on_scrape_ability: @scrape_task.scrape_ability_comment&.body,
              scraper: @scrape_task.scraper&.name,
              frequency: @scrape_task.frequency&.name,
              general_comment: @scrape_task.general_comment&.body,
              table_locations: @scrape_task.table_locations.map(&:full_name),
              data_sets: [@scrape_task.data_set&.id]
            },
            instruction: @scrape_task.instruction&.body,
            evaluation_document: @scrape_task.evaluation_doc&.body
          }
        end
      end
    end
  end
end

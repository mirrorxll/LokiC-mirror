# frozen_string_literal: true

module Api
  module V1
    module ScrapeTasks
      class MainController < ScrapeTasksController
        before_action :find_scrape_task, only: :show

        def index
          if params[:names]
            render json: ScrapeTask.all.map(&:name)
          else
            html_sanitizer = ActionView::Base.full_sanitizer

            render json: (ScrapeTask.all.map do |scrape_task|
              {
                number: scrape_task.id,
                created_by: scrape_task.creator&.name,
                scraper: scrape_task.scraper&.name,
                status: scrape_task.status.name,
                tags: scrape_task.tags.map(&:name),
                has_data_location: scrape_task.table_locations.present?,
                name: scrape_task.name,
                frequency: scrape_task.frequency&.name,
                deadline: scrape_task.deadline,
                general_comment: html_sanitizer.sanitize(scrape_task.general_comment&.body),
                created_at: scrape_task.created_at.utc
              }
            end)
          end
        end

        def show
          html_sanitizer = ActionView::Base.full_sanitizer

          render json: {
            status: @scrape_task.status.name,
            created_by: @scrape_task.creator.name,
            created_at: @scrape_task.created_at.utc,
            updated_at: @scrape_task.updated_at.utc,
            main_info: {
              tags: @scrape_task.tags.map(&:name),
              name: @scrape_task.name,
              multi_tasks: @scrape_task.multi_tasks.pluck(:id),
              gather_task_id: @scrape_task.gather_task,
              deadline: @scrape_task.deadline,
              state: @scrape_task.state&.name,
              URL: @scrape_task.datasource_url,
              comment_on_datasource: html_sanitizer.sanitize(@scrape_task.datasource_comment&.body),
              scrapable: @scrape_task.scrapable.eql?(-1) ? nil : @scrape_task.scrapable.eql?(1),
              comment_on_scrape_ability: html_sanitizer.sanitize(@scrape_task.scrape_ability_comment&.body),
              scraper: @scrape_task.scraper&.name,
              frequency: @scrape_task.frequency&.name,
              general_comment: html_sanitizer.sanitize(@scrape_task.general_comment&.body),
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

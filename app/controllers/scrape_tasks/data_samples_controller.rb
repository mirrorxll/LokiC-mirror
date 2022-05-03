# frozen_string_literal: true

module ScrapeTasks
  class DataSamplesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_scrape_task

    def index
      connections = {}

      @locations_columns = @scrape_task.table_locations.each_with_object({}) do |loc, obj|
        connections[loc.host_name] ||= MiniLokiC::Connect::Mysql.on(Object.const_get(loc.host_name))
        query = "SHOW COLUMNS FROM `#{loc.schema_name}`.`#{loc.table_name}`;"

        obj[loc.full_name] = { id: loc.id, list: connections[loc.host_name].query(query).to_a }
      end

      connections.each_value(&:close)
    end

    private

    def find_scrape_task
      @scrape_task = ScrapeTask.find(params[:scrape_task_id])
    end
  end
end

ArticleType.all.each do |factoid|
  staging_table = factoid.staging_table
  Table.add_default_article_type_columns(staging_table.name) if staging_table
end

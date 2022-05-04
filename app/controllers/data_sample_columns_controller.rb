# frozen_string_literal: true

class DataSampleColumnsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_model

  def index
    connections = {}

    @locations_columns = @model.table_locations.each_with_object({}) do |loc, obj|
      connections[loc.host_name] ||= MiniLokiC::Connect::Mysql.on(Object.const_get(loc.host_name))
      query = "SHOW COLUMNS FROM `#{loc.schema_name}`.`#{loc.table_name}`;"

      obj[loc.full_name] = { table_location_id: loc.id, list: connections[loc.host_name].query(query).to_a }
    end

    connections.each_value(&:close)
  end

  private

  def find_model
    @model = Object.const_get(params[:model]).find(params[:model_id])
  end
end

# frozen_string_literal: true

module Schemas
  class SqlTablesController < ApplicationController
    before_action :find_schema, only: :index

    def index
      render json: { tables: @schema.sql_tables.existing.order(:name).select(:id, :name) }
    end

    private

    def find_schema
      @schema = Schema.find(params[:schema_id])
    end
  end
end

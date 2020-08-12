# frozen_string_literal: true

class IndicesController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :staging_table
  before_action :index

  def new
    staging_table_action do
      @index.drop
      @staging_table.sync
      @columns = @staging_table.columns.names_ids
      nil
    end
  end

  def create
    staging_table_action { @index.add(uniq_index_params) }
    @staging_table.sync if flash.now[:error].nil?

    render 'staging_tables/show'
  end

  def destroy
    staging_table_action { @index.drop }
    @staging_table.sync if flash.now[:error].nil?

    render 'staging_tables/show'
  end

  private

  def uniq_index_params
    if params[:index]
      params.require(:index).permit(column_ids: [])[:column_ids].map!(&:to_sym)
    else
      []
    end
  end

  def staging_table
    @staging_table = @story_type.staging_table
  end

  def index
    @index = @staging_table.index
  end
end

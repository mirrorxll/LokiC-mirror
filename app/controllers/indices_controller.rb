# frozen_string_literal: true

class IndicesController < ApplicationController
  before_action :render_403, if: :editor?
  before_action :staging_table

  def new
    staging_table_action do
      @staging_table.index.drop
      @staging_table.sync
      @columns = @staging_table.reload.columns.names_ids
      nil
    end
  end

  def create
    staging_table_action do
      @staging_table.update(indices_modifying: true)
      StagingTableIndexAddJob.perform_later(@staging_table, uniq_index_params)
      nil
    end

    render 'staging_tables/show'
  end

  def destroy
    staging_table_action do
      @staging_table.update(indices_modifying: true)
      StagingTableIndexDropJob.perform_later(@staging_table)
      nil
    end

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
end

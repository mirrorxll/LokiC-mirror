# frozen_string_literal: true

class ColumnsController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :staging_table

  def edit
    staging_table_action { @staging_table.sync }
  end

  def update
    staging_table_action { @staging_table.columns.modify(columns_front_params) }
    @staging_table.sync if flash.now[:error].nil?

    render 'staging_tables/show'
  end

  private

  def columns_front_params
    columns =
      if params[:columns]
        params.require(:columns).permit!
      else
        {}
      end

    Table.columns_transform(columns, :front)
  end

  def staging_table
    @staging_table = @story_type.staging_table
  end
end

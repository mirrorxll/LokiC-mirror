# frozen_string_literal: true

class StagingTablesController < ApplicationController # :nodoc:
  before_action :attach_staging_table_params, only: %i[attach]
  before_action :create_staging_table_params, only: %i[create]
  before_action :update_staging_table_params, only: %i[update]

  def attach
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already attached. Please update the page'
      elsif StagingTable.find_by(name: @staging_table_params[:name])
        'This table already attached to another story type.'
      elsif !StagingTable.tbl_exists?(@staging_table_params[:name])
        'Table not found'
      end

    if flash[:error].nil?
      @story_type.create_staging_table(@staging_table_params)
    end

    render 'attach_create_update'
  end

  def detach
    @story_type.staging_table.delete

    render 'detach_delete'
  end

  def create
    flash[:error] =
      if @story_type.staging_table.present?
        'Table for this story type already exist. Please update page'
      end

    if flash[:error].nil?
      @staging_table = StagingTable.create(story_type: @story_type)
      @staging_table.create_tbl(@staging_table_columns)
    end

    render 'attach_create_update'
  end

  def edit
    @staging_table = @story_type.staging_table

    flash[:error] =
      if @staging_table.nil?
        'Table was attached or delete. Please update the page.'
      elsif !StagingTable.tbl_exists?(@staging_table.name)
        'Someone drop or table for this story type. Please check it.'
      end

    @staging_table.prepare_editable if flash[:error].nil?

    render 'edit'
  end

  def update
    @staging_table = @story_type.staging_table

    puts @staging_table.editable
    puts params.require(:staging_table).permit!
      .to_hash.each_with_object({}) { |(k, v), obj| obj[k] = v.deep_symbolize_keys }
    # flash[:error] =
    #   if StagingTable.exists?(@staging_table.name)
    #     @story_type.staging_table.modify(@staging_table_params)
    #   else
    #     'Table was removed or renamed.'
    #   end
    #
    # render 'attach_create_update'
  end

  def truncate
    @story_type.staging_table.truncate_tbl
  end

  def drop
    @story_type.staging_table.drop_tbl
    @story_type.staging_table.delete

    render 'detach_delete'
  end

  private

  def create_staging_table_params
    columns = params.require(:staging_table).permit!.to_hash
    @staging_table_columns =
      LokiC::StagingTable::Columns.transform_init(columns)
  end

  def attach_staging_table_params
    @staging_table_params =
      params.require(:staging_table).permit(:name)
  end

  def update_staging_table_params

  end
end

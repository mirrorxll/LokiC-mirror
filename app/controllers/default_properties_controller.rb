# frozen_string_literal: true

class DefaultPropertiesController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  before_action :find_data_set
  before_action :find_client, only: %i[include_client exclude_client]
  before_action :find_tag, only: %i[include_tag exclude_tag]
  before_action :default_property

  def include_client
    render_400 && return if @default_property.client_tag.key?(@client.id)

    @default_property.client_tag[@client.id] = nil
    @default_property.save
    @tags = @client.tags
  end

  def exclude_client
    @default_property.client_tag.delete(@client.id)
    @default_property.save
  end

  def include_tag
    @tag = Tag.find(params[:id])
    @client = Client.find(params[:client_id])
    @default_property.client_tag[params[:client_id].to_i] = @tag.id
    @default_property.save
  end

  def exclude_tag
    @tag = Tag.find(params[:id])
    @client = Client.find(params[:client_id])
    @default_property.client_tag[params[:client_id].to_i] = nil
    @default_property.save
  end

  def include_photo_bucket
    @photo_bucket = PhotoBucket.find(params[:id])
    @default_property.update(photo_bucket: @photo_bucket)
  end

  def exclude_photo_bucket
    @default_property.update(photo_bucket: nil)
  end

  private

  def default_property
    @default_property = @data_set.default_property
  end

  def find_data_set
    @data_set = DataSet.find(params[:data_set_id])
  end

  def find_client
    @client = Client.find(params[:id])
  end

  def find_tag
    @tag = Tag.find(params[:id])
  end
end

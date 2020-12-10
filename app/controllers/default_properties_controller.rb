# frozen_string_literal: true

class DefaultPropertiesController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :find_data_set
  before_action :find_photo_bucket, only: %i[include_photo_bucket exclude_photo_bucket]
  before_action :find_client_tags, except: %i[include_photo_bucket exclude_photo_bucket]
  before_action :find_client, only: %i[include_client exclude_client]

  def clients
    @clients = Client.where(hidden: false).pluck(:id, :name)
  end

  def tags_for_client
    @tags = Client.find(params[:client_id])
  end

  def include_client
    render_400 && return if @client_tags.find_by(client: @client)

    @data_set.clients << @client
    @client_tag = @client_tags.reload.find_by(client: @client)
  end

  def exclude_client
    @client_tags.reload.find_by(client: @client).delete
  end

  def include_tag
    @tag = Tag.find(params[:id])
    @client = Client.find(params[:client_id])
    @client_tags.reload.find_by(client: @client).update(tag: @tag)
  end

  def exclude_tag
    @client = Client.find(params[:client_id])
    @client_tags.reload.find_by(client: @client).update(tag: nil)
  end

  def include_photo_bucket
    @data_set.build_data_set_photo_bucket(photo_bucket: @photo_bucket).save!
  end

  def exclude_photo_bucket
    @data_set.data_set_photo_bucket.delete
  end

  private

  def find_client_tags
    @client_tags = @data_set.client_tags
  end

  def find_data_set
    @data_set = DataSet.find(params[:data_set_id])
  end

  def find_photo_bucket
    @photo_bucket = PhotoBucket.find(params[:id])
  end

  def find_client
    @client = Client.find(params[:id])
  end
end

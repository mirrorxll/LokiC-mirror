# frozen_string_literal: true

class TagsJob < ApplicationJob
  queue_as :default

  def perform
    PipelineReplica[:production].get_tags.each do |raw_tag|
      tag = Tag.find_or_initialize_by(pl_identifier: raw_tag['id'])
      tag.name = raw_tag['name']
      tag.save!
    end
  end
end

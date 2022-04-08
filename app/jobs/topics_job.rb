# frozen_string_literal: true

class TopicsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        LimparReplica[:production].get_topics.each do |raw_topic|
          topic             = Topic.find_or_initialize_by(external_lp_id: raw_topic['id'])
          topic.description = raw_topic['description']
          topic.deleted_at  = raw_topic['deleted_at']
          kinds             = raw_topic['kinds'][1...-1].split(',')
          kinds.each do |topic_kind|
            kind = Kind.parent_kinds.find_by(name: topic_kind)
            topic.kinds << kind unless topic.kinds.include?(kind)
          end
          topic.save!
        end
      end
    )
  end
end

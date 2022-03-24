# frozen_string_literal: true

class TopicsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        LimparReplica[:production].get_topics.each do |raw_topic|
          topic = Topic.find_or_initialize_by(external_lp_id: raw_topic['id'])
          topic.kind = raw_topic['kind']
          topic.description = raw_topic['description']
          topic.save!
        end
      end
    )
  end
end

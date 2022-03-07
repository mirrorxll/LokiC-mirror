# frozen_string_literal: true

class OpportunitiesJob < ApplicationJob
  queue_as :lokic

  def perform
    PipelineReplica[:production].get_opportunities
  end
end

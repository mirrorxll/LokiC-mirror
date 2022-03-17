# frozen_string_literal: true

class StoryTypeOpportunity < ApplicationRecord
  before_create do
    if publication.mm_or_lgis?
      self.opportunity = publication.opportunities.find_by("name like 'MM%baseline'")
      self.opportunity_type = OpportunityType.find_by(name: 'Baseline')
      self.content_type = ContentType.find_by(name: 'HLE')
    end
  end

  belongs_to :story_type
  belongs_to :client
  belongs_to :publication
  belongs_to :opportunity,      optional: true
  belongs_to :opportunity_type, optional: true
  belongs_to :content_type,     optional: true
end

StoryType.all.each do |st|
  StoryTypes::ChangeOpportunitiesListJob.perform_now(st)
end
# frozen_string_literal: true

class StoryTypeDefaultOpportunity < ApplicationRecord
  belongs_to :story_type
  belongs_to :client

  belongs_to :opportunity,      optional: true
  belongs_to :opportunity_type, optional: true
  belongs_to :content_type,     optional: true
end

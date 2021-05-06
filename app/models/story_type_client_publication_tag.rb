# frozen_string_literal: true

class StoryTypeClientPublicationTag < ApplicationRecord
  belongs_to :story_type
  belongs_to :client,      optional: true
  belongs_to :tag,         optional: true
  belongs_to :publication, optional: true
end

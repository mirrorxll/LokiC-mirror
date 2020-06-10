# frozen_string_literal: true

class StoryTypeClientTag < ApplicationRecord
  belongs_to :story_type
  belongs_to :client, optional: true
  belongs_to :tag,    optional: true
end

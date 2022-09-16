# frozen_string_literal: true

class LokiStoryCreatorRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :loki_story_creator }
end

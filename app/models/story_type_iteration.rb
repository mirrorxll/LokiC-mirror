# frozen_string_literal: true

class StoryTypeIteration < ApplicationRecord # :nodoc:
  belongs_to :story_type

  before_create { self.iteration = DateTime.now.to_s.gsub(/[^A-Za-z0-9]/, '') }
end

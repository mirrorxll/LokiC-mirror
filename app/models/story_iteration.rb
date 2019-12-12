# frozen_string_literal: true

class StoryIteration < ApplicationRecord # :nodoc:
  belongs_to :story

  before_create { self.iteration = DateTime.now.to_s.gsub(/[^A-Za-z0-9]/, '') }
end

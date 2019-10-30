# frozen_string_literal: true

class StoryTag < ApplicationRecord
  has_and_belongs_to_many :stories
end

# frozen_string_literal: true

class Level < ApplicationRecord
  has_many :story_types
end

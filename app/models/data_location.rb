# frozen_string_literal: true

class DataLocation < ApplicationRecord # :nodoc:
  has_many :story_types

  belongs_to :user
end

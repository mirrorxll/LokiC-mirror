# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :story_types
  has_and_belongs_to_many :iterations
end

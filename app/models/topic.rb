# frozen_string_literal: true

class Topic < ApplicationRecord
  has_and_belongs_to_many :kinds

  scope :actual, -> { where(deleted_at: nil) }
end

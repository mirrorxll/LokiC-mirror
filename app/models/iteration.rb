# frozen_string_literal: true

class Iteration < ApplicationRecord # :nodoc:
  belongs_to :story_type

  has_and_belongs_to_many :statuses
  has_many :samples, dependent: :destroy

  before_create { statuses << Status.first }
end

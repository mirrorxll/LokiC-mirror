# frozen_string_literal: true

class Iteration < ApplicationRecord # :nodoc:
  belongs_to :story_type

  has_many :stories, dependent: :destroy
end

# frozen_string_literal: true

class DataSet < ApplicationRecord # :nodoc:
  has_many :story_types

  belongs_to :user
  belongs_to :evaluator, optional: true, class_name: 'User'
end
